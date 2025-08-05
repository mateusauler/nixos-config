{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = config.modules.server;

  module-names = [ ];
in
{
  options.modules.server.enable = lib.mkEnableOption "server" // {
    default = osConfig.modules.server.enable;
    readOnly = true;
  };

  config = lib.mkIf cfg.enable {
    modules = pkgs.lib.enableModules module-names;
    dots.clone = false;
  };
}
