{ config, pkgs, lib, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  hardware.opengl.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    waybar-hyprland
    mako
    libnotify
    kitty
    swww
    rofi-wayland
    rofi-power-menu
    wlsunset
    copyq
    hyprpicker

    (builtins.getFlake "path:/etc/nixos/hyprshot").packages.x86_64-linux.default
  ];
}
