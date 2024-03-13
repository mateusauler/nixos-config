{ config, lib, pkgs, ... }:

let
  cfg = config.modules.eza;
in
{
  options.modules.eza.enable = pkgs.lib.mkTrueEnableOption "eza";
  config = lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;
      git = true;
      icons = true;
      extraOptions = [ "--group-directories-first" ];
    };
    shell-aliases = {
      llt = "lt -l";
      lat = "lt -a";
      llat = "lt -la";
    };
  };
}
