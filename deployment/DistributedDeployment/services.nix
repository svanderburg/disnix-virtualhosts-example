{ system, pkgs, distribution, invDistribution
, stateDir ? "/var"
, runtimeDir ? "${stateDir}/run"
, logDir ? "${stateDir}/log"
, cacheDir ? "${stateDir}/cache"
, spoolDir ? "${stateDir}/spool"
, libDir ? "${stateDir}/lib"
, tmpDir ? (if stateDir == "/var" then "/tmp" else "${stateDir}/tmp")
, forceDisableUserChange ? false
, processManager ? "systemd"
, nix-processmgmt ? ../../../nix-processmgmt
, nix-processmgmt-services ? ../../../nix-processmgmt-services
}:

let
  ids = if builtins.pathExists ./ids.nix then (import ./ids.nix).ids else {};

  customPkgs = import ../top-level/all-packages.nix {
    inherit pkgs system stateDir logDir runtimeDir tmpDir forceDisableUserChange processManager ids nix-processmgmt;
  };

  sharedConstructors = import "${nix-processmgmt-services}/services-agnostic/constructors.nix" {
    inherit nix-processmgmt pkgs stateDir logDir runtimeDir cacheDir spoolDir libDir tmpDir forceDisableUserChange processManager;
  };

  processType = import "${nix-processmgmt}/nixproc/derive-dysnomia-process-type.nix" {
    inherit processManager;
  };
in
{
  webapp1 = rec {
    name = "webapp1";
    dnsName = "webapp1.local";
    port = ids.webappPorts.webapp1 or 0;
    pkg = customPkgs.webappwrapper {
      inherit port;
      instanceSuffix = "1";
    };
    type = processType;
    requiresUniqueIdsFor = [ "webappPorts" "uids" "gids" ];
  };

  webapp2 = rec {
    name = "webapp2";
    dnsName = "webapp2.local";
    port = ids.webappPorts.webapp2 or 0;
    pkg = customPkgs.webappwrapper {
      inherit port;
      instanceSuffix = "2";
    };
    type = processType;
    requiresUniqueIdsFor = [ "webappPorts" "uids" "gids" ];
  };

  webapp3 = rec {
    name = "webapp3";
    dnsName = "webapp3.local";
    port = ids.webappPorts.webapp3 or 0;
    pkg = customPkgs.webappwrapper {
      inherit port;
      instanceSuffix = "3";
    };
    type = processType;
    requiresUniqueIdsFor = [ "webappPorts" "uids" "gids" ];
  };

  webapp4 = rec {
    name = "webapp4";
    dnsName = "webapp4.local";
    port = ids.webappPorts.webapp4 or 0;
    pkg = customPkgs.webappwrapper {
      inherit port;
      instanceSuffix = "4";
    };
    type = processType;
    requiresUniqueIdsFor = [ "webappPorts" "uids" "gids" ];
  };
} //

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
