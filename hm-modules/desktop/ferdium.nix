{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.ferdium;
in
{
  options.modules.ferdium = {
    enable = lib.mkEnableOption "ferdium";
    # FIXME: There is a bug with the current ferdium version, when running with wayland enabled
    enableWayland = lib.mkEnableOption "running under Wayland" // {
      default = config.modules.hyprland.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ (if cfg.enableWayland then pkgs.ferdium-wayland else pkgs.wayland) ];
  };
}
