{ lib, ... }:

let
  module-names = [ "desktop" "efi" "gaming" "virt-manager" ];
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  modules = lib.enableModules module-names;

  enabledUsers = [ "mateus" ];

  networking.hostName = "glados";

  system.stateVersion = "22.11";
}

