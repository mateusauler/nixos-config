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

    # TODO: Set colors based on nix-colors
    xdg.configFile."rofi/colors.rasi".text = ''
      * {
        bg0:    #2E3440F2;
        bg1:    #3B4252;
        bg2:    #4C566A80;
        bg3:    #88C0D0F2;
        fg0:    #D8DEE9;
        fg1:    #ECEFF4;
        fg2:    #D8DEE9;
        fg3:    #4C566A;
      }
    '';
  };
}
