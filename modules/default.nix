{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib) mkDefault;
  module-names = [ "appimage" "deploy-secrets" "openssh" ];
in
{
  options.hostBaseDir = lib.mkOption { default = ../hosts/${config.networking.hostName}; };

  imports = [
    ./appimage.nix
    ./barrier.nix
    ./deploy-secrets
    ./desktop.nix
    ./distrobox.nix
    ./efi.nix
    ./gaming.nix
    ./locale.nix
    ./localsend.nix
    ./nix.nix
    ./openssh.nix
    ./virt-manager
    ../users
    inputs.sops-nix.nixosModules.sops
  ];

  config = {

    sops.gnupg.sshKeyPaths = [ ];

    modules = lib.enableModules module-names;

    boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

    networking.networkmanager.enable = mkDefault true;

    console.font = mkDefault "Lat2-Terminus16";

    environment.enableAllTerminfo = true;
    environment.systemPackages = with pkgs; [
      dconf
      file
      ripgrep
      tree
      unzip
      zip
    ];

    # TODO: Handle this in home-manager
    programs.fish.enable = true;

    users = {
      mutableUsers = false;
      users.root = {
        hashedPassword = "!"; # Disable root password login
        shell = pkgs.fish;
      };
    };

    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = mkDefault true;
    };
  };
}
