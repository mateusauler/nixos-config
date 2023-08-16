{ config, lib, pkgs, ... }:

let
  cfg = config.modules.waybar;
in {
  options.modules.waybar.enable = lib.mkEnableOption "waybar";

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      package = lib.mkDefault pkgs.waybar-hyprland;
      settings.mainBar = import ./settings.nix;
      # TODO: Use nix-colors
      style = import ./style.nix;
    };
  };
}
