{
  config,
  lib,
  nixpkgs-channel,
  pkgs,
  ...
}:

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

  config = lib.mkIf cfg.enable {
    modules.desktop.autostart = "waybar";
    programs.waybar = {
      enable = true;
      package = if nixpkgs-channel == "unstable" then pkgs.waybar-git else pkgs.waybar;
    };
  };
}
