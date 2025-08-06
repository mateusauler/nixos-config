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
    ./pihole.nix
    ./syncthing.nix
    ./unifi.nix
    ./zfs.nix
  ];

  modules = lib.enableModules module-names { };
  enabledUsers = [ "mateus" ];

  networking.hostName = "amadeus";
  networking.hostId = "a40227d9";

  system.stateVersion = "23.11";
}
