{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.gtk;
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
        package = pkgs.arc-theme;
        name = "Arc-Dark";
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
