{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkDefault;
  cfg = config.modules.desktop;
  module-names = [
    "barrier"
    "distrobox"
    "localsend"
    "wally"
  ];
in
{
  options = {
    modules.desktop.enable = lib.mkEnableOption "desktop";
    defaultFonts =
      with lib.types;
      lib.mkOption {
        type = submodule {
          options =
            lib.foldl'
              (
                acc: name:
                acc
                // {
                  ${name} = lib.mkOption {
                    type = submodule {
                      options = {
                        package = lib.mkOption { };
                        name = lib.mkOption { };
                        size = lib.mkOption { };
                      };
                    };
                  };
                }
              )
              { }
              [
                "mono"
                "sans"
                "serif"
              ];
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
        hyprland.default = [
          "gtk"
          "hyprland"
        ];
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };

    defaultFonts = rec {
      sans = {
        package = lib.mkDefault pkgs.roboto;
        name = lib.mkDefault "Roboto";
        size = lib.mkDefault 12;
      };
      serif = sans;
      mono = {
        package = lib.mkDefault pkgs.nerdfonts;
        name = lib.mkDefault "FiraCode Nerd Font Mono";
        size = lib.mkDefault 12;
      };
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

    programs.fuse.userAllowOther = true;

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
      packages =
        with pkgs;
        [
          font-awesome
          liberation_ttf
          nerdfonts
          noto-fonts
          noto-fonts-cjk
          noto-fonts-emoji
        ]
        ++ (with config.defaultFonts; [
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

    programs.kdeconnect.enable = true;

    programs.adb.enable = true;

    environment.systemPackages = with pkgs; [
      nodejs
      pwvucontrol
    ];
  };
}
