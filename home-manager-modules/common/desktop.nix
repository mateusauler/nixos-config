{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.desktop;
  inherit (lib) mkDefault;
in {
  options.modules.desktop.enable = lib.mkEnableOption "desktop";

  imports = [
    ../hyprland
    ../librewolf.nix
    ../gtk
    ../qt.nix
  ];

  config = lib.mkIf cfg.enable {
    modules = {
      hyprland.enable = mkDefault true;
      gtk.enable = mkDefault true;
      qt.enable = mkDefault true;
      librewolf.enable = mkDefault true;
    };
  };
}