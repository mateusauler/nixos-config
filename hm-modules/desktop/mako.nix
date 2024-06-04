{ config, lib, ... }:

let
  cfg = config.modules.mako;
in
{
  options.modules.mako.enable = lib.mkEnableOption "mako";

  config = lib.mkIf cfg.enable {
    services.mako = {
      enable = true;
      borderRadius = 5;
      borderSize = 2;
      ignoreTimeout = true;
      defaultTimeout = 15000;
    };
  };
}
