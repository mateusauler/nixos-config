{ inputs, config, lib, pkgs, ... }:

let
  module-names = [
    "desktop"
    "waybar.battery"
  ];
in
{
  imports = [ ../../home-manager-modules ];

  modules = pkgs.lib.enableModules module-names // {
    hyprland.extraAutostart = {
      networkmanagerapplet = "nm-applet";
    };
    git.gpgKey = "5D9269C32D1E49D278A4410C263716004E5EF18D";
    power-menu.actions.set.firmware.enable = false;
  };

  # TODO: Check if the nm-applet home-manager service would be a better idea
  home.packages = [ pkgs.networkmanagerapplet ];

  home.stateVersion = "22.11";
}
