{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.distrobox;
  module-names = [ "docker" ];
in
{
  options.modules.distrobox.enable = lib.mkEnableOption "Distrobox";

  config = lib.mkIf cfg.enable {
    modules = lib.enableModules module-names;
    environment.systemPackages = [ pkgs.distrobox ];
  };
}
