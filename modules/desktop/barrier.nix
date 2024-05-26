{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.barrier;
in
{
  options.modules.barrier = {
    enable = lib.mkEnableOption "barrier";
    ports = lib.mkOption { default = [ 24800 ]; };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.barrier ];
    networking.firewall.allowedTCPPorts = cfg.ports;
  };
}
