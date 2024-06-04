{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.xresources;
in
{
  options.modules.xresources.enable = lib.mkEnableOption "xresources";

  config = lib.mkIf cfg.enable {
    modules.hyprland.extraAutostart.load-xresources =  "${lib.getExe pkgs.xorg.xrdb} ${config.xresources.path}";
  };
}
