{ pkgs, ... }:

{
  # ssh
  services.openssh.enable = true;
  security.rtkit.enable = true;
  networking.firewall = {
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 22 ];
  };
}