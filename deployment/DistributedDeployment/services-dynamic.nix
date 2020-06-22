{ system, pkgs, distribution, invDistribution
, stateDir ? "/var"
, runtimeDir ? "${stateDir}/run"
, logDir ? "${stateDir}/log"
, cacheDir ? "${stateDir}/cache"
, tmpDir ? (if stateDir == "/var" then "/tmp" else "${stateDir}/tmp")
, forceDisableUserChange ? false
, processManager ? "systemd"
}:

let
  customPkgs = import ../top-level/all-packages.nix {
    inherit pkgs system stateDir logDir runtimeDir tmpDir forceDisableUserChange processManager;
  };

  sharedConstructors = import ../../../nix-processmgmt/examples/services-agnostic/constructors.nix {
    inherit pkgs stateDir logDir runtimeDir cacheDir tmpDir forceDisableUserChange processManager;
  };

  processType = import ../../../nix-processmgmt/nixproc/derive-dysnomia-process-type.nix {
    inherit processManager;
  };

  portsConfiguration = if builtins.pathExists ./ports.nix then import ./ports.nix else {};

  # Adjust this function invocation to increase the number of services to be deployed
  numbers = pkgs.lib.range 1 4;

  webappSuffixes = map (value: toString value) numbers;
in

# Generate a predefined number of web application services

builtins.listToAttrs (map (instanceSuffix: {
  name = "webapp${instanceSuffix}";
  value = rec {
    name = "webapp${instanceSuffix}";
    dnsName = "${name}.local";
    pkg = customPkgs.webappwrapper {
      inherit port instanceSuffix;
    };
    type = processType;
    portAssign = "shared";
    port = portsConfiguration.ports."${name}" or 0;
    weight = 1;
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
      pkg = sharedConstructors.nginxReverseProxyHostBased {};
      dependsOn = builtins.removeAttrs ((builtins.getAttr targetName invDistribution).services) [ serviceName ]; # The reverse proxy depends on all services distributed to the same machine, except itself (of course)
      type = processType;
    };
  }
) (builtins.attrNames invDistribution))
