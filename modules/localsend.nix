{ config, lib, pkgs, ... }:

let
  cfg = config.modules.localsend;
in
{
  options.modules.localsend.enable = lib.mkEnableOption "LocalSend";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.localsend ];
    networking.firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };
}
