{ config, lib, pkgs, ... }:

let
  cfg = config.modules.mako;
in {
  options.modules.mako.enable = lib.mkEnableOption "mako";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.mako ];
    xdg.configFile."mako/config" = {
      enable = true;
      text = ''
        default-timeout=15000
        ignore-timeout=1
      '';
    };
  };
}

