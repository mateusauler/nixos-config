{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.desktop;
  module-names = [
    "barrier"
    "distrobox"
    "niri"
    "pipewire"
    "protonvpn"
    "wally"
  ];
in
{
  options = {
    modules.desktop.enable = lib.mkEnableOption "desktop";
  };

  imports = [
    ./barrier.nix
    ./bluetooth.nix
    ./distrobox.nix
    ./gaming.nix
    ./niri.nix
    ./pipewire.nix
    ./protonvpn.nix
    ./virt-manager
    ./wally.nix
  ];

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

    xdg.portal = {
      enable = true;
      config = {
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

    modules = lib.enableModules module-names { };

    programs = {
      adb.enable = true;
      fuse.userAllowOther = true;
      kdeconnect.enable = true;
      localsend.enable = true;
      wireshark = {
        enable = true;
        package = pkgs.wireshark;
      };
    };

    environment.systemPackages = with pkgs; [
      pwvucontrol
    ];
  };
}
