{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.gtk;
in
{
  options.modules.gtk.enable = lib.mkEnableOption "gtk";

  config = {
    # Ensures the cursor icon always works
    xdg.dataFile."icons/default/index.theme" = {
      inherit (cfg) enable;
      text = # ini
        ''
          [Icon Theme]
          Name=Default
          Comment=Default Cursor Theme
          Inherits=${config.stylix.cursor.name}
        '';
    };
    gtk =
      let
        commonConfigs = {
          gtk-application-prefer-dark-theme = true;
          gtk-decoration-layout = "menu:none";
          gtk-enable-animations = true;
          gtk-error-bell = 0;
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
      in
      {
        enable = lib.mkForce cfg.enable;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
        gtk2 = {
          configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc-2.0";
          extraConfig = lib.strings.concatLines (
            lib.attrsets.foldlAttrs (
              acc: name: value:
              acc
              ++ [
                (
                  "${name}="
                  + (
                    if builtins.typeOf value == "string" then
                      (if lib.hasPrefix "GTK_" value then value else "\"${value}\"")
                    else if builtins.typeOf value == "bool" then
                      (if value then "1" else "0")
                    else
                      toString value
                  )
                )
              ]
            ) [ ] commonConfigs
          );
        };
        gtk3.extraConfig = commonConfigs;
        gtk4.extraConfig = commonConfigs;
      };
  };
}
