{ pkgs, ... }:

let
  module-names = [
    "desktop"
    "waybar.battery"
  ];
in
{
  modules = pkgs.lib.enableModules module-names // {
    hyprland.extraAutostart = {
      networkmanagerapplet = "nm-applet";
    };
    git.gpgKey = "37C12B2664A4FFBC42E743B24D551E363428C47E";
    power-menu.actions.set.firmware.enable = false;
  };

  # TODO: Check if the nm-applet home-manager service would be a better idea
  home.packages = [ pkgs.networkmanagerapplet ];

  home.stateVersion = "22.11";
}
