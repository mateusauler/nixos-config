{ pkgs, options, config, lib, ... }:

let
  inherit (lib) mkDefault;
  cfg = config.modules.openssh;
in {
  options.modules.openssh.enable = lib.mkEnableOption "openssh";

  config = lib.mkIf cfg.enable {
    services.openssh.enable = true;
    security.rtkit.enable = mkDefault true;
    networking.firewall = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 22 ];
    };
  };
}