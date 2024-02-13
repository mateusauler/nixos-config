{ config, lib, pkgs, ... }:

let
  cfg = config.modules.swaylock;
in
{
  options.modules.swaylock.enable = lib.mkEnableOption "Swaylock";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swaylock-effects ];
    # TODO: Allow for extra configurations
    xdg.configFile."swaylock/config".text = with config.colorScheme.palette; ''
      clock
      screenshots
      show-failed-attempts

      fade-in=0.2
      grace=0

      indicator
      indicator-radius=100
      indicator-thickness=7

      effect-pixelate=100
      effect-vignette=0.5:0.5

      inside-color=${base00}88
      key-hl-color=${base04}
      line-color=00000000
      ring-color=${base0D}
      separator-color=00000000
      text-color=${base05}
    '';
  };
}
