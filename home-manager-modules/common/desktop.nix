{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.desktop;
  inherit (lib) mkDefault;
in {
  options.modules.desktop.enable = lib.mkEnableOption "desktop";

  config = lib.mkIf cfg.enable {
    modules = {
      base.enable = true;
      hyprland.enable = mkDefault true;
      gtk.enable = mkDefault true;
      qt.enable = mkDefault true;
      librewolf.enable = mkDefault true;
    };
  };
}