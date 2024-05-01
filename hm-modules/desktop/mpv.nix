{ config, lib, ... }:

let
  cfg = config.modules.mpv;
in {
  options.modules.mpv.enable = lib.mkEnableOption "mpv";

  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      config.save-position-on-quit = true;
    };
  };
}
