{ config, lib, pkgs, ... }:

let
  cfg = config.modules.mako;
in {
  options.modules.mako.enable = lib.mkEnableOption "mako";

  config = lib.mkIf cfg.enable {
    services.mako = with config.colorScheme.colors; {
      enable = true;
      backgroundColor = "#${base01}";
      borderColor = "#${base0E}";
      borderRadius = 5;
      borderSize = 2;
      textColor = "#${base04}";
      ignoreTimeout = true;
      defaultTimeout = 15000;
    };
  };
}

