{ lib, ... }:

let
  module-names = [ "desktop" "zswap" ];
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda";
    };
    timeout = 0;
  };

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable grub cryptodisk
  boot.loader.grub.enableCryptodisk = true;
  boot.initrd.luks.devices."luks-c058bec9-bb26-440c-805c-75808b15c20d".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "wheatley";

  modules = lib.enableModules module-names;

  enabledUsers = [ "mateus" ];

  system.stateVersion = "23.05";
}
