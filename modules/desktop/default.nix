{ config, lib, pkgs, ... }:

let
  inherit (lib) mkDefault;
  cfg = config.modules.desktop;
  module-names = [ "barrier" "distrobox" "localsend" "wally" ];
in
{
  options = {
    modules.desktop.enable = lib.mkEnableOption "desktop";
    defaultFonts = lib.mkOption {
      default = rec {
        sans = {
          package = pkgs.roboto;
          name = "Roboto";
          size = 12;
        };
        serif = sans;
        mono = {
          package = pkgs.nerdfonts;
          name = "FiraCode Nerd Font Mono";
          size = 12;
        };
      };
    };
  };

  imports = [
    ./barrier.nix
    ./bluetooth.nix
    ./distrobox.nix
    ./gaming.nix
    ./localsend.nix
    ./virt-manager
    ./wally.nix
  ];

  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      config = {
        common.default = [ "gtk" ];
        hyprland.default = [ "gtk" "hyprland" ];
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };

    sound.enable = true;

    services = {
      pipewire = {
        enable = mkDefault true;
        alsa = {
          enable = mkDefault true;
          support32Bit = mkDefault true;
        };
        pulse.enable = mkDefault true;
        jack.enable = mkDefault true;
      };

      mullvad-vpn = {
        enable = mkDefault true;
        package = mkDefault pkgs.mullvad-vpn;
      };
    };

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    modules = lib.enableModules module-names;

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        font-awesome
        liberation_ttf
        nerdfonts
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
      ] ++ (with config.defaultFonts; [
        sans.package
        serif.package
        mono.package
      ]);
      fontconfig.defaultFonts = with config.defaultFonts; {
        sansSerif = [ sans.name ];
        serif = [ serif.name ];
        monospace = [ mono.name ];
      };
    };

    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    environment.systemPackages = with pkgs; [
      nodejs
      pwvucontrol
    ];
  };
}
