{system, pkgs, distribution, invDistribution}:

let
  customPkgs = import ../top-level/all-packages.nix {
    inherit pkgs system;
  };
  
  portsConfiguration = if builtins.pathExists ./ports.nix then import ./ports.nix else {};
  
  # Adjust this function invocation to increase the number of services to be deployed
  numbers = pkgs.lib.range 1 4;
  
  webappNames = map (value: "webapp${toString value}") numbers;
in

# Generate a predefined number of web application services

pkgs.lib.genAttrs webappNames (name: rec {
  inherit name;
  dnsName = "${name}.local";
  pkg = customPkgs.webappwrapper { inherit port; };
  type = "process";
  portAssign = "shared";
  port = portsConfiguration.ports."${name}" or 0;
  weight = 1;
})

//

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
