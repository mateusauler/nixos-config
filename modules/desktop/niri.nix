{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.niri;
in
{
  options.modules.niri.enable = lib.mkEnableOption "niri";

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    systemd.user.services.polkit-gnome-authentication-agent-1.enable =
      lib.mkIf config.programs.niri.enable (lib.mkForce false);
    services.gnome.gnome-keyring.enable = lib.mkIf config.programs.niri.enable (lib.mkForce false);
  };
}
