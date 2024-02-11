{ lib, ... }:

let
  module-names = [ "server" ];
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-path/pci-0000:00:1d.0-usb-0:1.4:1.0-scsi-0:0:0:0";

  modules = lib.enableModules module-names;

  enabledUsers = [ "mateus" ];

  networking.hostName = "amadeus";

  system.stateVersion = "23.11";
}

