{ config, lib, pkgs, ... }:

let
  cfg = config.modules.xresources;
  xresources = "${config.xdg.configHome}/X11/Xresources";
  load-xresources = "${lib.getExe pkgs.xorg.xrdb} ${xresources}";
in {
  options.modules.xresources.enable = lib.mkEnableOption "xresources";

  config = lib.mkIf cfg.enable {
    modules.hyprland.extraAutostart = { inherit load-xresources; };
	  home = {
	    packages = [ pkgs.xorg.xrdb ];
      file.${xresources} = {
        enable = true;
        text = with config.colorScheme.palette; ''
          #ifdef background_opacity
            *background: [background_opacity]#${base00}
          #else
            *background: #${base00}
          #endif
          *foreground:   #${base05}
          *cursorColor:  #${base05}

          *color0:       #${base00}
          *color1:       #${base08}
          *color2:       #${base0B}
          *color3:       #${base0A}
          *color4:       #${base0D}
          *color5:       #${base0E}
          *color6:       #${base0C}
          *color7:       #${base05}

          *color8:       #${base03}
          *color9:       #${base08}
          *color10:      #${base0B}
          *color11:      #${base0A}
          *color12:      #${base0D}
          *color13:      #${base0E}
          *color14:      #${base0C}
          *color15:      #${base07}

          *color16:      #${base09}
          *color17:      #${base0F}
          *color18:      #${base01}
          *color19:      #${base02}
          *color20:      #${base04}
          *color21:      #${base06}
        '';
        onChange = ''
          [ ! -z "$DISPLAY" ] && ${load-xresources}
        '';
      };
    };
  };
}

