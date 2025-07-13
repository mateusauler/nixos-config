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
    modules.wayland.file-manager = "dolphin";
    modules.xdg.file-manager = "dolphin.desktop";
    home.packages = [ pkgs.kdePackages.dolphin ];
  };
}
