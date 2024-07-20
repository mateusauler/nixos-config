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

    modules = lib.enableModules module-names;

    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

      image = pkgs.fetchurl {
        url = "https://github.com/mateusauler/wallpapers/blob/251702e9f3431938cddb2a3b2094c141f6b16317/tropic_island_night.jpg?raw=true";
        sha256 = "Fm800h7CbEHqcPDL7oKSBSIpGBhEWLFS6ioV5qM0SVw=";
      };

      opacity = {
        terminal = 0.8;
      };

      cursor = {
        package = pkgs.qogir-icon-theme;
        name = "Qogir";
        size = 24;
      };

      fonts = {
        sizes = {
          applications = lib.mkDefault 12;
          desktop = lib.mkDefault 10;
          popups = lib.mkDefault 10;
          terminal = lib.mkDefault 12;
        };

        monospace = {
          name = "FiraCode Nerd Font Mono";
          package = pkgs.nerdfonts;
        };

        sansSerif = {
          name = "Roboto";
          package = pkgs.roboto;
        };

        serif = config.stylix.fonts.sansSerif;

        emoji = {
          name = "Blobmoji";
          package = pkgs.noto-fonts-emoji-blob-bin;
        };
      };
    };

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        font-awesome
        liberation_ttf
        nerdfonts
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts-emoji-blob-bin
      ];
    };

    boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

    networking.networkmanager.enable = mkDefault true;

    console.font = mkDefault "Lat2-Terminus16";

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
