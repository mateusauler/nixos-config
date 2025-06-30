{ config, lib, ... }:

let
  gui-port = 8384;
in
{
  services.syncthing = {
    configDir = "/var/lib/syncthing/config";
    dataDir = "/tank/syncthing";
    guiAddress = "0.0.0.0:${builtins.toString gui-port}";
  };

  networking.firewall.interfaces.wt0.allowedTCPPorts =
    lib.optional config.services.syncthing.enable gui-port;
}
