{ config, lib, pkgs, ... }:

let
  cfg = config.modules.gaming;
in
{
  options.modules.gaming.enable = lib.mkEnableOption "Gaming";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lutris
      heroic
      prismlauncher
    ];
    programs.steam.enable = true;
  };
}
