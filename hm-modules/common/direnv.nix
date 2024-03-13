{ config, lib, ... }:

let
  inherit (lib) mkDefault;
  cfg = config.modules.direnv;
in
{
  options.modules.direnv.enable = lib.mkEnableOption "direnv";

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableBashIntegration = mkDefault true;
      nix-direnv.enable = mkDefault true;
      config.global.warn_timeout = "10h";
    };
  };
}
