{ config, lib, pkgs, ... }:

let
  cfg = config.modules.hyprland;
  inherit (lib) mkDefault;
in {
  options.modules.hyprland.enable = lib.mkEnableOption "hyprland";

  imports = [
    ../waybar
    ../rofi
  ];

  config = lib.mkIf cfg.enable {
    modules = {
      waybar.enable = mkDefault true;
      rofi.enable = mkDefault true;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemdIntegration = mkDefault true;
      xwayland.enable = mkDefault true;
      settings = import ./settings.nix;
    };

    home.file.".config/hypr/autostart.sh" = {
      executable = true;
      source = ./autostart.sh;
    };
  };
}