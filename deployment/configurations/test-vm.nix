{ pkgs, ... }:

{
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 ];
  services.disnix.enable = true;
  
  environment.systemPackages = [
    pkgs.w3m
  ];
  
  users.extraGroups = {
    nginx = { gid = 60; };
  };
  
  users.extraUsers = {
    nginx = { group = "nginx"; uid = 60; };
  };
}
