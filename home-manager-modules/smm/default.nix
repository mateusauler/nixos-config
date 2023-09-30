{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.smm;

  package = pkgs.stdenv.mkDerivation rec {
    name = "satisfactory-mod-manager";

    src = pkgs.appimageTools.wrapType2 {
      inherit name;
      src = inputs.satisfactory-mod-manager;
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src/bin/satisfactory-mod-manager $out/bin
    '';

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postFixup = ''
      wrapProgram $out/bin/satisfactory-mod-manager \
        ${lib.optionalString config.modules.steam-xdg.enable ("--set HOME " + config.modules.steam-xdg.fakeHome)}
    '';
  };
in
{
  options.modules.smm.enable = lib.mkEnableOption "Satisfactory Mod Manager";

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];
  };
}
