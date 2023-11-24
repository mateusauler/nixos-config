{ config, lib, pkgs, custom, inputs, ... }:

let
  inherit (custom) username;
  inherit (lib) mkDefault;
  module-names = [ "appimage" "deploy-gpg" "deploy-ssh" "openssh" ];
in
{
  imports = [
    ./appimage.nix
    ./barrier.nix
    ./deploy-gpg.nix
    ./deploy-ssh.nix
    ./desktop.nix
    ./efi.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./virt-manager
    inputs.sops-nix.nixosModules.sops
  ];

  sops.gnupg.sshKeyPaths = [ ];

  modules = pkgs.lib.enableModules module-names;

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = mkDefault true;
  };
}
