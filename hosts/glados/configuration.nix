{ lib, pkgs, ... }:

let
  module-names = [
    "desktop"
    "efi"
    "gaming"
    "virt-manager"
  ];
in
{
  imports = [ ./hardware-configuration.nix ];

  modules = lib.enableModules module-names;

  enabledUsers = [ "mateus" ];

  networking.hostName = "glados";

  environment.systemPackages = [ pkgs.refind ];

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };

  system.stateVersion = "22.11";
}
