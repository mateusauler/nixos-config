{ config, lib, nix-colors, pkgs, ... }:

let
  cfg = config.modules.bat;
  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
in
{
  options.modules.bat.enable = lib.mkEnableOption "bat";

  config = lib.mkIf cfg.enable {
    home.sessionVariables.MANPAGER = "${pkgs.bat}/bin/bat -l man -p";
    programs.bat =
      let
        inherit (config.colorScheme) slug;
      in
      {
        enable = true;
        config.theme = slug;
        themes.${slug}.src = nix-colors-lib.textMateThemeFromScheme { scheme = config.colorScheme; };
      };
  };
}
