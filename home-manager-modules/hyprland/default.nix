{ config, lib, pkgs, ... }:

let
  cfg = config.modules.hyprland;
  inherit (lib) mkDefault;
in {
  options.modules.hyprland = {
    enable = lib.mkEnableOption "hyprland";
    monitors = lib.mkOption {
      default = {
        "$mon1" = "";
        "$mon2" = "$mon1";
        "$mon3" = "$mon2";

        # monitor = name,resolution,position,scale
        monitor = [
          "$mon1,prefered,auto,1"
        ];

        workspace = [];
      };
    };
  };

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
      settings = config.modules.hyprland.monitors // (import ./settings.nix);
    };

    home.file.".config/hypr/autostart.sh" = {
      executable = true;
      source = ./autostart.sh;
    };
  };
}