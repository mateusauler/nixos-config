{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.smm;

  icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/satisfactorymodding/SatisfactoryModManager/b346711bb9c9ee27c235c2b425b588f3e8996b90/icons/512x512.png";
    hash = "sha256-VJoOzvlcdGgpbfflW5aMAIUbOlG0bQY/dvnrKu2kDVk=";
  };

  name = "satisfactory-mod-manager";
  version = "2.9.3";

  desktopItem = pkgs.makeDesktopItem {
    inherit name;
    desktopName = "Satisfactory Mod Manager";
    exec = name;
    icon = name;
  };

  package = pkgs.appimageTools.wrapType2 {
    inherit name;

    src = pkgs.fetchurl {
      url = "https://github.com/satisfactorymodding/SatisfactoryModManager/releases/download/v${version}/Satisfactory-Mod-Manager.AppImage";
      hash = "sha256-KIHdfdmb2yh70e6uSvJG24m5jjwMw1nABhiNBvEPegQ=";
    };

    extraInstallCommands = ''
      install -D ${icon.outPath} $out/share/icons/${name}.png
      cp -r ${desktopItem} $out
    '';

    fixupPhase =
      with config.modules.steam-xdg;
      lib.optionalString enable "wrapProgram $out/bin/${name} --set HOME ${fakeHome}";
  };
in
{
  options.modules.smm.enable = lib.mkEnableOption "Satisfactory Mod Manager";

  config = lib.mkIf cfg.enable { home.packages = [ package ]; };
}
