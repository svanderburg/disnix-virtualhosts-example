{ system, pkgs, distribution, invDistribution
, stateDir ? "/var"
, runtimeDir ? "${stateDir}/run"
, logDir ? "${stateDir}/log"
, cacheDir ? "${stateDir}/cache"
, tmpDir ? (if stateDir == "/var" then "/tmp" else "${stateDir}/tmp")
, forceDisableUserChange ? false
, processManager ? "systemd"
, numOfServices ? 10
, nix-processmgmt ? ../../../nix-processmgmt
}:

let
  ids = if builtins.pathExists ./ids.nix then (import ./ids.nix).ids else {};

  customPkgs = import ../top-level/all-packages.nix {
    inherit pkgs system stateDir logDir runtimeDir tmpDir forceDisableUserChange processManager nix-processmgmt;
  };

  sharedConstructors = import "${nix-processmgmt}/examples/services-agnostic/constructors.nix" {
    inherit pkgs stateDir logDir runtimeDir cacheDir tmpDir forceDisableUserChange processManager;
  };

  processType = import "${nix-processmgmt}/nixproc/derive-dysnomia-process-type.nix" {
    inherit processManager;
  };

  numbers = pkgs.lib.range 1 numOfServices;

  webappSuffixes = map (value: toString value) numbers;
in

# Generate a predefined number of web application services

builtins.listToAttrs (map (instanceSuffix: {
  name = "webapp${instanceSuffix}";
  value = rec {
    name = "webapp${instanceSuffix}";
    dnsName = "${name}.local";
    port = ids.ports."${name}" or 0;
    pkg = customPkgs.webappwrapper {
      inherit port instanceSuffix;
    };
    type = processType;
    weight = 1;
    requiresUniqueIdsFor = [ "webappPorts" "uids" "gids" ];
  };
}) webappSuffixes)

//

# Generate nginx proxy per target host

builtins.listToAttrs (map (targetName:
  let
    serviceName = "nginx-reverse-proxy-${targetName}";
  in
  { name = serviceName;
    value = {
      name = serviceName;
      pkg = sharedConstructors.nginxReverseProxyHostBased {
        port = 80;
      };
      dependsOn = builtins.removeAttrs ((builtins.getAttr targetName invDistribution).services) [ serviceName ]; # The reverse proxy depends on all services distributed to the same machine, except itself (of course)
      type = processType;
    };
  }
) (builtins.attrNames invDistribution))
