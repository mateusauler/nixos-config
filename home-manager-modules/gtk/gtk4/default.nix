{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.gtk;
in {
  config = lib.mkIf cfg.enable {
    gtk.gtk4.extraConfig = {
      "gtk-application-prefer-dark-theme" = true;
      "gtk-decoration-layout" = "icon:minimize,maximize,close";
      "gtk-enable-animations" = true;
      "gtk-font-name" = "Noto Sans,  10";
      "gtk-primary-button-warps-slider" = false;
      "gtk-xft-dpi" = 98304;
    };
  };
}
