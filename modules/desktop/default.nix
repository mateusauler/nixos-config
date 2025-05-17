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
    "localsend"
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
    ./localsend.nix
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
