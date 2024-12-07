{
  appimageTools,
  fetchurl,
  lib,
  makeDesktopItem,
  steamFakeHome ? null,
  steamXdg ? false,
}:

let
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/satisfactorymodding/SatisfactoryModManager/b346711bb9c9ee27c235c2b425b588f3e8996b90/icons/512x512.png";
    hash = "sha256-VJoOzvlcdGgpbfflW5aMAIUbOlG0bQY/dvnrKu2kDVk=";
  };

  name = "satisfactory-mod-manager";
  version = "2.9.3";

  desktopItem = makeDesktopItem {
    inherit name;
    desktopName = "Satisfactory Mod Manager";
    exec = name;
    icon = name;
  };

in
appimageTools.wrapType2 {
  inherit name version;

  pname = name;

  src = fetchurl {
    url = "https://github.com/satisfactorymodding/SatisfactoryModManager/releases/download/v${version}/Satisfactory-Mod-Manager.AppImage";
    hash = "sha256-KIHdfdmb2yh70e6uSvJG24m5jjwMw1nABhiNBvEPegQ=";
  };

  extraInstallCommands = ''
    install -D ${icon.outPath} $out/share/icons/${name}.png
    cp -r ${desktopItem} $out
  '';

  fixupPhase = lib.optionalString steamXdg "wrapProgram $out/bin/${name} --set HOME ${steamFakeHome}";
}
