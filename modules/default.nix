{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) mkDefault;
  module-names = [
    "appimage"
    "deploy-secrets"
    "openssh"
  ];
in
{
  options.hostBaseDir = lib.mkOption { default = ../hosts/${config.networking.hostName}; };

  imports = [
    ./common
    ./desktop
    ./server
    ./style.nix
    ../users
    inputs.sops-nix.nixosModules.sops
  ];

  config = {
    sops.gnupg.sshKeyPaths = [ ];

    modules = lib.enableModules module-names;

    boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

    networking.networkmanager.enable = mkDefault true;
    networking.useDHCP = lib.mkDefault true;

    home-manager.backupFileExtension = "hm-backup";

    environment = {
      enableAllTerminfo = true;
      systemPackages = with pkgs; [
        dconf
        fd
        file
        ripgrep
        tree
        unzip
        zip
      ];
    };

    services.udisks2 = {
      enable = mkDefault true;
      mountOnMedia = mkDefault true;
    };

    services.swapspace.enable = mkDefault true;

    # Don't allow non-wheel users to execute the sudo binary
    security.sudo.execWheelOnly = true;

    security.pam.services = {
      login.nodelay = true;
      sudo.nodelay = true;
      swaylock.nodelay = true;
    };

    programs = {
      fish.enable = true;
      nix-ld.enable = true;
      mtr.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = mkDefault true;
      };
    };
  };
}
