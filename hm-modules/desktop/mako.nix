{ config, lib, ... }:

let
  cfg = config.modules.mako;
in
{
  options.modules.mako.enable = lib.mkEnableOption "mako";

  config = lib.mkIf cfg.enable {
    services.mako = {
      enable = true;
      settings = {
        border-radius = 5;
        border-size = 2;
        ignore-timeout = true;
        default-timeout = 15000;
      };
    };
  };
}
