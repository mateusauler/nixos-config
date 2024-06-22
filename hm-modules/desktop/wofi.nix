{ config, lib, ... }:

let
  cfg = config.modules.wofi;
in
{
  options.modules.wofi.enable = lib.mkEnableOption "wofi";

  config = lib.mkIf cfg.enable {
    programs.wofi = {
      enable = true;
      settings = {
        allow_images = true;
        columns = 3;
        image_size = 24;
        insensitive = true;
        lines = 10;
        run-always_parse_args = true;
        run-exec_search = true;
        width = 700;
      };
    };
  };
}
