{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.gtk;
in {
  config = lib.mkIf cfg.enable {
    gtk.gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc-2.0";
      extraConfig = ''
        gtk-enable-animations=1
        gtk-primary-button-warps-slider=0
        gtk-toolbar-style=3
        gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
        gtk-button-images=1
        gtk-menu-images=1
        gtk-enable-event-sounds=1
        gtk-enable-input-feedback-sounds=1
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintfull"
        gtk-xft-rgba="rgb"
      '';
    };
  };
}