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
    ../users
    inputs.sops-nix.nixosModules.sops
  ];

  config = {

    sops.gnupg.sshKeyPaths = [ ];

    stylix = {
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      image = pkgs.fetchurl {
        url = "https://github.com/mateusauler/wallpapers/blob/251702e9f3431938cddb2a3b2094c141f6b16317/tropic_island_night.jpg?raw=true";
        sha256 = "Fm800h7CbEHqcPDL7oKSBSIpGBhEWLFS6ioV5qM0SVw=";
      };
    };

    modules = pkgs.lib.enableModules module-names;

    boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

    networking.networkmanager.enable = mkDefault true;

    console.font = mkDefault "Lat2-Terminus16";

    environment.enableAllTerminfo = true;
    environment.systemPackages = with pkgs; [
      dconf
      fd
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
