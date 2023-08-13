{ pkgs, ... }:

{
  # ssh
  services.openssh.enable = true;
  security.rtkit.enable = true;
  networking.firewall = {
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 22 ];
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}