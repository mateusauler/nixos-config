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
    git.gpgKey = "47A8B3AF49EE54114A4F2081E5350C9F8A536581";
    power-menu.actions.set.firmware.enable = false;
  };

  # TODO: Check if the nm-applet home-manager service would be a better idea
  home.packages = [ pkgs.networkmanagerapplet ];

  home.stateVersion = "22.11";
}
