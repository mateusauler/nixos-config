{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.gtk;
in {
  config = lib.mkIf cfg.enable {
    gtk.gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = true;
      "gtk-button-images" = true;
      "gtk-decoration-layout" = "icon:minimize,maximize,close";
      "gtk-enable-animations" = true;
      "gtk-enable-event-sounds" = 1;
      "gtk-enable-input-feedback-sounds" = 1;
      "gtk-menu-images" = true;
      "gtk-modules" = "colorreload-gtk-module";
      "gtk-primary-button-warps-slider" = false;
      "gtk-toolbar-icon-size" = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      "gtk-toolbar-style" = 3;
      "gtk-xft-antialias" = 1;
      "gtk-xft-dpi" = 98304;
      "gtk-xft-hinting" = 1;
      "gtk-xft-hintstyle" = "hintfull";
      "gtk-xft-rgba" = "rgb";
    };
  };
}