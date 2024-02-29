{ config, lib, pkgs, ... }:

let
  cfg = config.modules.eza;
in
{
  options.modules.eza.enable = pkgs.lib.mkTrueEnableOption "eza";
  config = lib.mkIf cfg.enable {
    programs.eza.enable = true;
    shell-aliases = rec {
      ls = "eza --group-directories-first --icons --git";
      lt = "${ls} --tree";
      llt = "${lt} -l";
      lat = "${lt} -a";
      llat = "${lt} -la";
    };
  };
}
