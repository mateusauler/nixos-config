{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib) mkDefault;
  module-names = [ "appimage" "deploy-secrets" "openssh" ];
in
{
  options.hostBaseDir = lib.mkOption { default = ../hosts/${config.networking.hostName}; };

  imports = [
    ./common
    ./desktop
    ./server
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

    services.udisks2 = {
      enable = mkDefault true;
      mountOnMedia = mkDefault true;
    };

    # Don't allow non-wheel users to execute the sudo binary
    security.sudo.execWheelOnly = true;

    # FIXME: Only enable this if swaylock is installed
    security.pam.services.swaylock = { };

    # TODO: Handle this in home-manager
    programs.fish.enable = true;

    programs.nix-ld.enable = true;

    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = mkDefault true;
    };
  };
}
