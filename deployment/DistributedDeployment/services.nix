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
in
{
  webapp1 = rec {
    name = "webapp1";
    dnsName = "webapp1.local";
    pkg = customPkgs.webappwrapper {
      inherit port;
      instanceSuffix = "1";
    };
    type = processType;
    portAssign = "shared";
    port = portsConfiguration.ports.webapp1 or 0;
  };

  webapp2 = rec {
    name = "webapp2";
    dnsName = "webapp2.local";
    pkg = customPkgs.webappwrapper {
      inherit port;
      instanceSuffix = "2";
    };
    type = processType;
    portAssign = "shared";
    port = portsConfiguration.ports.webapp2 or 0;
  };

  webapp3 = rec {
    name = "webapp3";
    dnsName = "webapp3.local";
    pkg = customPkgs.webappwrapper {
      inherit port;
      instanceSuffix = "3";
    };
    type = processType;
    portAssign = "shared";
    port = portsConfiguration.ports.webapp3 or 0;
  };

  webapp4 = rec {
    name = "webapp4";
    dnsName = "webapp4.local";
    pkg = customPkgs.webappwrapper {
      inherit port;
      instanceSuffix = "4";
    };
    type = processType;
    portAssign = "shared";
    port = portsConfiguration.ports.webapp4 or 0;
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
      pkg = sharedConstructors.nginxReverseProxyHostBased { port = 80; };
      dependsOn = builtins.removeAttrs ((builtins.getAttr targetName invDistribution).services) [ serviceName ]; # The reverse proxy depends on all services distributed to the same machine, except itself (of course)
      type = processType;
    };
  }
) (builtins.attrNames invDistribution))
