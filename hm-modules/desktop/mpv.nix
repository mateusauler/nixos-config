{ config, lib, ... }:

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
      };
      config.save-position-on-quit = true;
    };
  };
}
