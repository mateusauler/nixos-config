{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.niri;
in
{
  options.modules.niri.enable = lib.mkEnableOption "niri";

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;

    systemd.user.services.polkit-gnome-authentication-agent-1.enable = lib.mkForce false;
    services.gnome.gnome-keyring.enable = lib.mkForce false;
  };
}
