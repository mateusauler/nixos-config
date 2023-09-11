{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.rofi;
in {
  options.modules.rofi.enable = lib.mkEnableOption "rofi";

  config = lib.mkIf cfg.enable {
    programs = {
      rofi = {
        enable = true;
        cycle = true;
        package = pkgs.rofi-wayland;
        terminal = "${lib.getBin pkgs.kitty}/bin/kitty";
        theme = ./theme.rasi;
        extraConfig = {
          modi = "run,drun,ssh,window";
          show-icons = true;
        };
      };
    };

    xdg.configFile."rofi/colors.rasi".text = with config.colorScheme.colors; ''
      * {
        bg0:    #${base00}F2;
        bg1:    #${base01};
        bg2:    #${base03}80;
        bg3:    #${base0C}F2;
        fg0:    #${base04};
        fg1:    #${base06};
        fg2:    #${base04};
        fg3:    #${base03};
      }
    '';
  };
}
