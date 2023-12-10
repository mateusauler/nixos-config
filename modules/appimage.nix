{ config, lib, pkgs, ... }:

let
  cfg = config.modules.appimage;
in
{
  options.modules.appimage.enable = lib.mkTrueEnableOption "Appimage format recognition";

  config = lib.mkIf cfg.enable {
    # Enable running appimages as executables, by setting appimage-run as the interpreter
    # https://nixos.wiki/wiki/Appimage
    boot.binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };
}
