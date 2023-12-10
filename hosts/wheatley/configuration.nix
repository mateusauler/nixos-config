{ config, pkgs, custom, ... }:

let
  module-names = [ "desktop" ];
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../users/mateus
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

  # https://github.com/NixOS/nixpkgs/issues/119244#issuecomment-1250321791
  systemd.services.zswap = {
    description = "Enable ZSwap, set to ZSTD and Z3FOLD";
    enable = true;
    wantedBy = [ "basic.target" ];
    path = [ pkgs.bash ];
    serviceConfig = {
      ExecStart = ''${pkgs.bash}/bin/bash -c 'cd /sys/module/zswap/parameters && \
        echo 1 > enabled && \
        echo 20 > max_pool_percent && \
        echo zstd > compressor && \
        echo z3fold > zpool'
      '';
      Type = "simple";
    };
  };

  modules = lib.enableModules module-names;

  system.stateVersion = "23.05";
}
