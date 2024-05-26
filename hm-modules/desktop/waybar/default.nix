{ config, lib, ... }:

let
  cfg = config.modules.waybar;
in
{
  options.modules.waybar = {
    enable = lib.mkEnableOption "Waybar";
    battery.enable = lib.mkEnableOption "Battery";
  };

  imports = [
    ./settings.nix
    ./style.nix
  ];

  config = lib.mkIf cfg.enable { programs.waybar.enable = true; };
}
