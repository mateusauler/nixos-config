{ lib, ... }:

let
  module-names = [ "server" "zswap" ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./google-ddns.nix
  ];

  modules = lib.enableModules module-names;

  enabledUsers = [ "mateus" ];

  networking.hostName = "amadeus";

  services.google-ddns.enable = true;

  system.stateVersion = "23.11";
}

