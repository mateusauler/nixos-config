{ pkgs, lib, specialArgs, ... }:

{
  hardware.opengl.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; with specialArgs.flakePkgs; [
    mako
    libnotify
    kitty
    swww
    rofi-power-menu
    wlsunset
    copyq
    hyprpicker
    hyprshot
  ];
}
