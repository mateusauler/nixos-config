{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.mpv;
in
{
  options.modules.mpv.enable = lib.mkEnableOption "mpv";

  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;

      bindings = {
        WHEEL_UP    = "seek  5";
        WHEEL_DOWN  = "seek -5";
        WHEEL_RIGHT = "add volume  2";
        WHEEL_LEFT  = "add volume -2";
        # Rebind default to override sponsorblock's bind
        "Shift+g" = "add sub-scale +0.1";
      };

      config = {
        osc = false;
        save-position-on-quit = true;
      };

      scriptOpts = {
        uosc = {
          autohide = true;
          top_bar_controls = false;
        };
        sponsorblock.skip_categories = "interaction,selfpromo,sponsor";
      };

      scripts = with pkgs.mpvScripts; [
        mpv-cheatsheet
        quality-menu
        sponsorblock
        thumbfast
        uosc
      ];
    };
  };
}
