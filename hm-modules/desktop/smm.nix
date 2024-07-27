{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.smm;

  package = pkgs.satisfactory-mod-manager.overrideAttrs (
    old: with config.modules.steam-xdg; {
      steamXdg = enable;
      steamFakeHome = fakeHome;
    }
  );
in
{
  options.modules.smm.enable = lib.mkEnableOption "Satisfactory Mod Manager";

  config = lib.mkIf cfg.enable { home.packages = [ package ]; };
}
