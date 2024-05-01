{ config, lib, ... }:

let
  cfg = config.modules.wofi;
in {
  options.modules.wofi.enable = lib.mkEnableOption "wofi";

  config = lib.mkIf cfg.enable {
    programs = {
      wofi = {
        enable = true;
        settings = {
          image_size = 24;
          columns = 3;
          lines = 10;
          width = 700;
          allow_images = true;
          insensitive = true;
          normal_window = true;
          run-always_parse_args = true;
          run-cache_file = "/dev/null";
          run-exec_search = true;
        };
      };
    };
  };
}
