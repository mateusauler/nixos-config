{ config, lib, pkgs, ... }:

let
  cfg = config.modules.qt;
in
{
  options.modules.qt.enable = lib.mkEnableOption "qt";

  config = {
    qt = {
      inherit (cfg) enable;
      platformTheme = "gtk";
      style = config.gtk.theme;
    };
  };
}
