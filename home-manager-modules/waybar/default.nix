{ config, lib, pkgs, ... }:

let
  cfg = config.modules.waybar;
in {
  options.modules.waybar = {
    enable = lib.mkEnableOption "waybar";
    battery.enable = lib.mkEnableOption "battery";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.pavucontrol ];
    programs.waybar = {
      enable = true;
      package = lib.mkDefault pkgs.waybar-hyprland;
      settings.mainBar = (import ./settings.nix) { config = cfg; };
      # TODO: Use nix-colors
      style = builtins.readFile ./style.css;
    };
  };
}
