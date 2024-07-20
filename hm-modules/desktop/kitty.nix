{ config, lib, ... }:

let
  cfg = config.modules.kitty;
in
{
  options.modules.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      settings = {
        font_family = config.stylix.fonts.monospace.name;
        font_size = config.stylix.fonts.sizes.terminal;
        enable_audio_bell = false;
        scrollback_lines = 20000;
      };
      shellIntegration.enableFishIntegration = lib.mkDefault true;
    };
  };
}