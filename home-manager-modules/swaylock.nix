{ config, lib, pkgs, ... }:

let
  cfg = config.modules.swaylock;
in
{
  options.modules.swaylock.enable = lib.mkEnableOption "Swaylock";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swaylock-effects ];
    # TODO: Use nix-colors
    # TODO: Allow for extra configurations
    xdg.configFile."swaylock/config".text = ''
      screenshots
      clock
      indicator
      indicator-radius=100
      indicator-thickness=7
      effect-blur=30x8
      effect-vignette=0.5:0.5
      ring-color=bb00cc
      key-hl-color=880033
      line-color=00000000
      inside-color=00000088
      separator-color=00000000
      fade-in=0.2
      show-failed-attempts
    '';
  };
}
