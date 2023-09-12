{ config, lib, nix-colors, pkgs, ... }:

let
  cfg = config.modules.gtk;
  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
in {
  imports = [
    ./gtk2
    ./gtk3
    ./gtk4
  ];

  options.modules.gtk.enable = lib.mkEnableOption "gtk";

  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;
      theme = {
        package = nix-colors-lib.gtkThemeFromScheme {
          scheme = config.colorScheme;
        };
        name = "${config.colorScheme.slug}";
      };
      cursorTheme = {
        package = pkgs.qogir-icon-theme;
        name = "Qogir";
      };
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };
    };
  };
}
