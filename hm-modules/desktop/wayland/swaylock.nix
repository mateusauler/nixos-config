{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.swaylock;
in
{
  options.modules.swaylock.enable = lib.mkEnableOption "Swaylock";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swaylock-effects ];
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        clock = true;
        screenshots = true;
        show-failed-attempts = true;

        fade-in = 0.2;
        grace = 0;

        indicator = true;
        indicator-radius = 100;
        indicator-thickness = 7;

        effect-pixelate = 100;
        effect-vignette = "0.5:0.5";
      };
    };
  };
}
