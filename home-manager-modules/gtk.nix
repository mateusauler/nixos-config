{ config, custom, lib, nix-colors, pkgs, ... }:

let
  cfg = config.modules.gtk;
  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
in {
  options.modules.gtk.enable = lib.mkEnableOption "gtk";

  config = lib.mkIf cfg.enable {
    gtk = let
      commonConfigs = {
        gtk-application-prefer-dark-theme = true;
        gtk-decoration-layout = "menu:none";
        gtk-enable-animations = true;
        gtk-font-name = "${custom.font-sans.name}, ${toString custom.font-sans.size}";
        gtk-menu-images = true;
        gtk-primary-button-warps-slider = false;
        gtk-titlebar-double-click = "menu";
        gtk-titlebar-middle-click = "none";
        gtk-titlebar-right-click = "none";
        gtk-toolbar-icon-size = "GTK_ICON_SIZE_SMALL_TOOLBAR";
        gtk-toolbar-style = "GTK_TOOLBAR_BOTH";
        gtk-xft-antialias = 1;
        gtk-xft-dpi = 98304;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintfull";
        gtk-xft-rgba = "rgb";
      };
    in {
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
      gtk2 = {
        configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc-2.0";
        extraConfig = lib.strings.concatLines
          (lib.attrsets.foldlAttrs
            (acc: name: value:
              acc ++ [
                ("${name}=" + (
                  if      builtins.typeOf value == "string" then (if lib.strings.hasPrefix "GTK_" value then value else "\"${value}\"")
                  else if builtins.typeOf value == "bool"   then (if value then "1" else "0")
                  else                                           toString value
                ))
              ]
            )
            [ ]
            commonConfigs
          );
      };
      gtk3.extraConfig = commonConfigs;
      gtk4.extraConfig = commonConfigs;
    };
  };
}
