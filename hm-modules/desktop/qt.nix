{ config, lib, nixpkgs-channel, pkgs, ... }:

let
  cfg = config.modules.qt;
in
{
  options.modules.qt.enable = lib.mkEnableOption "qt";

  config = {
    qt = {
      inherit (cfg) enable;
      platformTheme = if nixpkgs-channel == "stable" then "gtk" else { name = "gtk"; };
      style = config.gtk.theme;
    };
  };
}
