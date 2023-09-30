{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.smm;

  package = pkgs.stdenv.mkDerivation (finalAttrs: rec {
    name = "satisfactory-mod-manager";

    src = pkgs.appimageTools.wrapType2 {
      inherit name;
      src = inputs.satisfactory-mod-manager;
    };

    dontUnpack = true;
    nativeBuildInputs = with pkgs; [
      copyDesktopItems
      makeWrapper
    ];

    desktopItems = [
      (pkgs.makeDesktopItem rec {
        name = "Satisfactory Mod Manager";
        exec = finalAttrs.name;
        icon = finalAttrs.name;
        desktopName = name;
        genericName = name;
      })
    ];

    installPhase = ''
      mkdir -p $out/bin $out/share/applications $out/share/icons

      copyDesktopItems

      cp ${inputs.satisfactory-mod-manager-icon.outPath} $out/share/icons/${name}.png

      cp $src/bin/satisfactory-mod-manager $out/bin
    '';

    fixupPhase = with config.modules.steam-xdg; lib.optionalString enable "wrapProgram $out/bin/satisfactory-mod-manager --set HOME ${fakeHome}";
  });
in
{
  options.modules.smm.enable = lib.mkEnableOption "Satisfactory Mod Manager";

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];
  };
}
