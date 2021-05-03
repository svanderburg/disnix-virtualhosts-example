{ pkgs, ... }:

{
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 ];
  services.disnix.enable = true;
  services.openssh.enable = true;

  dysnomia.properties = {
    capacity = 10;
  };

  environment.systemPackages = [
    pkgs.w3m
  ];
}
