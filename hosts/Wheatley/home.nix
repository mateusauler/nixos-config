{ inputs, config, lib, pkgs, ... }:

{
  imports = [ ../../home-manager-modules ];

  modules = {
    desktop.enable = true;
    waybar.battery.enable = true;
    hyprland.extraAutostart = {
      networkmanagerapplet = "nm-applet";
    };
    git.gpgKey = "5D9269C32D1E49D278A4410C263716004E5EF18D";
    power-menu.actions.firmware.enable = false;
  };

  # TODO: Check if the nm-applet home-manager service would be a better idea
  home.packages = [ pkgs.networkmanagerapplet ];

  home.stateVersion = "22.11";
}
