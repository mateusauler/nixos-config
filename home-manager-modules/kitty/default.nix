{ config, lib, pkgs, specialArgs, ... }:

let
  cfg = config.modules.kitty;
in {
  options.modules.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      extraConfig = (builtins.readFile ./kitty.conf);
      shellIntegration.enableFishIntegration = lib.mkDefault true;
    };
  };
}