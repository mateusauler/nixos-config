{ config, lib, pkgs, specialArgs, ... }:

let
  cfg = config.modules.ferdium;
in {
  options.modules.ferdium.enable = lib.mkEnableOption "ferdium";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ferdium ];
  };
}
