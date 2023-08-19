{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.gtk;
  inherit (pkgs) qogir-icon-theme;
in {
  imports = [
    ./gtk2
    ./gtk3
    ./gtk4
  ];

  options.modules.gtk.enable = lib.mkEnableOption "gtk";

  config = lib.mkIf cfg.enable {
    home.packages = [ qogir-icon-theme ];
    gtk = {
      enable = true;
      theme = {
        package = pkgs.arc-theme;
        name = "Arc-Dark";
      };
      cursorTheme = {
        package = qogir-icon-theme;
        name = "Qogir";
      };
      iconTheme = {
        package = qogir-icon-theme;
        name = "Qogir-dark";
      };
    };
  };
}
