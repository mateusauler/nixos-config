{
  config,
  lib,
  osConfig,
  ...
}:

let
  cfg = config.modules.kitty;
in
{
  options.modules.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      settings = {
        font_family = osConfig.defaultFonts.mono.name;
        font_size = osConfig.defaultFonts.mono.size;
        enable_audio_bell = false;
      };
      extraConfig = (builtins.readFile ./kitty.conf);
      shellIntegration.enableFishIntegration = lib.mkDefault true;
    };
  };
}
