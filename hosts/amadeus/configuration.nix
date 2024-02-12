{ lib, ... }:

let
  module-names = [ "server" ];
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  modules = lib.enableModules module-names;

  enabledUsers = [ "mateus" ];

  networking.hostName = "amadeus";

  system.stateVersion = "23.11";
}

