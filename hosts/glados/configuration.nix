{ lib, ... }:

let
  module-names = [ "desktop" "efi" "gaming" "virt-manager" ];
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../users/mateus
  ];

  modules = lib.enableModules module-names;

  networking.hostName = "glados";

  system.stateVersion = "22.11";
}

