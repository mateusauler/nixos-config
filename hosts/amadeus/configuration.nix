{ lib, ... }:

let
  module-names = [
    "proxy"
    "server"
    "syncthing"
    "zswap"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./pihole.nix
    ./nixarr.nix
    ./proxy.nix
    ./syncthing.nix
    ./unifi.nix
    ./zfs.nix
  ];

  modules = lib.enableModules module-names { };
  enabledUsers = [ "mateus" ];

  networking.hostName = "amadeus";
  networking.hostId = "a40227d9";

  services.swapspace.enable = false;

  system.stateVersion = "23.11";
}
