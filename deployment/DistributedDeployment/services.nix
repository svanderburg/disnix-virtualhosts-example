{system, pkgs, distribution, invDistribution}:

let
  customPkgs = import ../top-level/all-packages.nix {
    inherit pkgs system;
  };
  
  portsConfiguration = if builtins.pathExists ./ports.nix then import ./ports.nix else {};
in
{
  webapp1 = rec {
    name = "webapp1";
    dnsName = "webapp1.local";
    pkg = customPkgs.webappwrapper { inherit port; };
    type = "process";
    portAssign = "shared";
    port = portsConfiguration.ports.webapp1 or 0;
  };
  
  webapp2 = rec {
    name = "webapp2";
    dnsName = "webapp2.local";
    pkg = customPkgs.webappwrapper { inherit port; };
    type = "process";
    portAssign = "shared";
    port = portsConfiguration.ports.webapp2 or 0;
  };
  
  webapp3 = rec {
    name = "webapp3";
    dnsName = "webapp3.local";
    pkg = customPkgs.webappwrapper { inherit port; };
    type = "process";
    portAssign = "shared";
    port = portsConfiguration.ports.webapp3 or 0;
  };
  
  webapp4 = rec {
    name = "webapp4";
    dnsName = "webapp4.local";
    pkg = customPkgs.webappwrapper { inherit port; };
    type = "process";
    portAssign = "shared";
    port = portsConfiguration.ports.webapp4 or 0;
  };
} //

# Generate nginx proxy per target host

builtins.listToAttrs (map (targetName:
  let
    serviceName = "nginx-wrapper-${targetName}";
  in
  { name = serviceName;
    value = {
      name = serviceName;
      pkg = customPkgs.nginx-wrapper;
      dependsOn = builtins.removeAttrs ((builtins.getAttr targetName invDistribution).services) [ serviceName ]; # The reverse proxy depends on all services distributed to the same machine, except itself (of course)
      type = "wrapper";
    };
  }
) (builtins.attrNames invDistribution))
