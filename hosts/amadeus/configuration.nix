{ lib, ... }:

let
  module-names = [
    "server"
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

  enabledUsers = [ "mateus" ];

  networking.hostName = "amadeus";
  networking.hostId = "a40227d9";

  system.stateVersion = "23.11";
}
