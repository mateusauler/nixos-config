{ inputs, config, lib, pkgs, ... }:

{
  imports = [ ../../home-manager-modules/base.nix ];

  modules = {
    desktop.enable = true;
    waybar.battery.enable = true;
    hyprland.extraAutostart = {
      networkmanagerapplet = "nm-applet";
    };
  };

  # TODO: Check if the nm-applet home-manager service would be a better idea
  home.packages = [ pkgs.networkmanagerapplet ];

  home.stateVersion = "22.11";
}
