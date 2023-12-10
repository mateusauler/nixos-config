{ lib, ... }:

let
  module-names = [ "desktop" "efi" "virt-manager" ];
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../users/mateus
  ];

  modules = lib.enableModules module-names;

  networking.hostName = "glados";

  programs.steam.enable = true;

  system.stateVersion = "22.11";
}

