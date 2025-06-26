{ lib, ... }:

let
  module-names = [
    "server"
    "syncthing"
    "zswap"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./rustdesk.nix
    ./zfs.nix
  ];

  modules = lib.enableModules module-names;

  services.syncthing = {
    configDir = "/var/lib/syncthing/config";
    dataDir = "/tank/syncthing";
    guiAddress = "0.0.0.0:8384";
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];

  enabledUsers = [ "mateus" ];

  networking.hostName = "amadeus";
  networking.hostId = "a40227d9";

  system.stateVersion = "23.11";
}
