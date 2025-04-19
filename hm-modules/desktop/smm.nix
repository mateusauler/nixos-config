{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.smm;

  package = pkgs.satisfactorymodmanager.overrideAttrs (
    old: with config.modules.steam-xdg; {
      fixupPhase = lib.optionalString enable "wrapProgram $out/bin/SatisfactoryModManager --set HOME ${fakeHome}";
    }
  );
in
{
  options.modules.smm.enable = lib.mkEnableOption "Satisfactory Mod Manager";

  config = lib.mkIf cfg.enable { home.packages = [ package ]; };
}
