{ pkgs, ... }:

let
  module-names = [
    "waybar.battery"
  ];
in
{
  modules = pkgs.lib.enableModules module-names {
    desktop.autostart = "nm-applet";
    git.gpgKey = "82BE10715363265100DF88519AEA7E01F75F5E92";
    power-menu.actions.set.firmware.enable = false;
  };

  # TODO: Check if the nm-applet home-manager service would be a better idea
  home.packages = [ pkgs.networkmanagerapplet ];

  home.stateVersion = "22.11";
}
