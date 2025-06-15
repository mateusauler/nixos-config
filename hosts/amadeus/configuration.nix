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
    ./google-ddns.nix
    ./rustdesk.nix
    ./zfs.nix
  ];

  modules = lib.enableModules module-names;

  enabledUsers = [ "mateus" ];

  networking.hostName = "amadeus";
  networking.hostId = "a40227d9";

  services.google-ddns.enable = true;
  services.rustdesk-server.enable = true;

  system.stateVersion = "23.11";
}
