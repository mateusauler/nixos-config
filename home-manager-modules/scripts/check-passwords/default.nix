{ config, pkgs, lib, ... }:

let
  package = pkgs.python3.pkgs.buildPythonPackage {
    name = "check-passwords";

    format = "other";
    dontUnpack = true;

    src.outPath = ./check-passwords.py;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/check-passwords
      chmod +x $out/bin/check-passwords
    '';

    buildInputs = with pkgs; [
      (python3.withPackages (ps: with ps; [ requests ]))
      keepassxc
    ];
  };

  cfg = config.modules.check-passwords;
in
{
  options.modules.check-passwords.enable = lib.mkEnableOption "check-passwords";

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];
  };
}
