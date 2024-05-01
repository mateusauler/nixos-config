{ config, lib, pkgs, ... }:

let
  cfg = config.modules.server;

  module-names = [ ];
in
{
  options.modules.server.enable = lib.mkEnableOption "server";

  config = lib.mkIf cfg.enable {
    modules = pkgs.lib.enableModules module-names;
    dots.clone = false;
  };
}
