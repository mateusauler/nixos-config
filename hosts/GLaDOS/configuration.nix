{ pkgs, custom, ... }:

let
  inherit (custom) username;
  module-names = [ "desktop" "efi" "openssh" "virt-manager" ];
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../users/mateus
  ];

  modules = pkgs.lib.enableModules module-names;

  networking.hostName = "GLaDOS";

  programs.steam.enable = true;

  system.stateVersion = "22.11";
}

