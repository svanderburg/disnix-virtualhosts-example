{pkgs, system}:

let
  callPackage = pkgs.lib.callPackageWith (pkgs // self);
  
  self = {
    webapp = (import ../../services/webapp {
      inherit system pkgs;
    }).package;
    
    webappwrapper = callPackage ../pkgs/webapp/wrapper.nix { };
  
    nginx-wrapper = callPackage ../pkgs/nginx-wrapper { };
  };
in
self
