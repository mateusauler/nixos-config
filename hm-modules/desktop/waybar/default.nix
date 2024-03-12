{ config, lib, pkgs, ... }:

let
  cfg = config.modules.waybar;
in {
  options.modules.waybar = {
    enable = lib.mkEnableOption "Waybar";
    battery.enable = lib.mkEnableOption "Battery";
  };

  imports = [
    ./settings.nix
    ./style.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.pavucontrol ];
    programs.waybar.enable = true;
  };
}
