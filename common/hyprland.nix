{ pkgs, lib, specialArgs, ... }:

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

  environment.systemPackages = with pkgs; with specialArgs.flakePkgs; [
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
    hyprshot
  ];
}
