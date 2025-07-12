{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  systemd.user.services.polkit-gnome-authentication-agent-1.enable =
    lib.mkIf config.programs.niri.enable (lib.mkForce false);
  services.gnome.gnome-keyring.enable = lib.mkIf config.programs.niri.enable (lib.mkForce false);
}
