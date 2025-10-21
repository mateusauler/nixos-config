{
  config,
  lib,
  options,
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
        background-color = lib.mkForce "#000000";
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
    services = lib.optionalAttrs (options.services ? jellyfin-mpv-shim) {
      jellyfin-mpv-shim = {
        enable = true;
        settings = {
          connect_retry_mins = 1;
          mpv_ext = true;
          mpv_ext_path = lib.getExe config.programs.mpv.finalPackage;
          remote_kbps = 2147483;
        };
      };
    };
  };
}
