{ lib, ... }:

let
  module-names = [ "server" "zswap" ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./google-ddns.nix
    ./rustdesk.nix
  ];

  modules = lib.enableModules module-names;

  enabledUsers = [ "mateus" ];

  networking.hostName = "amadeus";

  services.google-ddns.enable = true;
  services.rustdesk-server.enable = true;

  system.stateVersion = "23.11";
}

