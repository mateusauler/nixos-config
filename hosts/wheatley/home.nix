{ pkgs, ... }:

let
  module-names = [
    "desktop"
    "waybar.battery"
  ];
in
{
  modules = pkgs.lib.enableModules module-names // {
    desktop.autostart = "nm-applet";
    git.gpgKey = "A09DC0933C374BFC2B5A269F80A5D62F6EB7D9F0";
    power-menu.actions.set.firmware.enable = false;
  };

  # TODO: Check if the nm-applet home-manager service would be a better idea
  home.packages = [ pkgs.networkmanagerapplet ];

  home.stateVersion = "22.11";
}
