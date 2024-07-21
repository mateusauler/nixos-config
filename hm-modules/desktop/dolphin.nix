{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.dolphin;
in
{
  options.modules.dolphin.enable = pkgs.lib.mkEnableOption "Dolphin file manager";

  config = lib.mkIf cfg.enable {
    modules.hyprland.file-manager = "dolphin";
    modules.xdg.file-manager = "dolphin.desktop";
    home.packages = [ pkgs.libsForQt5.dolphin ];
  };
}
