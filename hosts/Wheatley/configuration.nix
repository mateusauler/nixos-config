{ config, pkgs, custom, ... }:

{
  imports = [ ./hardware-configuration.nix ../../common ];

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
  boot.loader.grub.enableCryptodisk=true;

  boot.initrd.luks.devices."luks-c058bec9-bb26-440c-805c-75808b15c20d".keyFile = "/crypto_keyfile.bin";
  networking.hostName = "Wheatley";

  modules = {
    desktop.enable = true;
    openssh.enable = true;
  };

  system.stateVersion = "23.05";
}
