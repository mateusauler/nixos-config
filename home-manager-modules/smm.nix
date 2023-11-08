{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.smm;

  icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/satisfactorymodding/SatisfactoryModManager/b346711bb9c9ee27c235c2b425b588f3e8996b90/icons/512x512.png";
    hash = "sha256-VJoOzvlcdGgpbfflW5aMAIUbOlG0bQY/dvnrKu2kDVk=";
  };

  package = pkgs.stdenv.mkDerivation (finalAttrs: rec {
    name = "satisfactory-mod-manager";

    src = pkgs.appimageTools.wrapType2 {
      inherit name;
      src = pkgs.fetchurl {
        url = "https://github.com/satisfactorymodding/SatisfactoryModManager/releases/download/v2.9.3/Satisfactory-Mod-Manager.AppImage";
        hash = "sha256-KIHdfdmb2yh70e6uSvJG24m5jjwMw1nABhiNBvEPegQ=";
      };
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
      cp ${icon.outPath} $out/share/icons/${name}.png
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
