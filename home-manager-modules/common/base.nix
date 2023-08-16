{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.base;
  inherit (lib) mkDefault;
in {
  options.modules.base.enable = lib.mkEnableOption "base";

  config = lib.mkIf cfg.enable {
    modules = {
      fish.enable = mkDefault true;
    };
  };
}