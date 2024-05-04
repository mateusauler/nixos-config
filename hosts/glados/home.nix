{ pkgs, ... }:

let
  module-names = [
    "desktop"
    "libvirtd"
    "steam-xdg"
    "smm"
  ];
in
{
  modules = pkgs.lib.enableModules module-names // {
    hyprland.extraOptions = {
      "$mon1" = "DP-3";
      "$mon2" = "HDMI-A-1";
      "$mon3" = "$mon2";

      # monitor = name,resolution,position,scale
      monitor = [
        "$mon1,prefered,1920x0,auto"
        "$mon2,prefered,0x360,auto"
      ];
    };
    git.gpgKey = "37C12B2664A4FFBC42E743B24D551E363428C47E";
  };

  wayland.windowManager.hyprland.settings = {
    workspace = [
      "1, monitor:$mon1"
      "2, monitor:$mon1"
      "3, monitor:$mon1"
      "4, monitor:$mon3"
      "5, monitor:$mon2"
      "6, monitor:$mon2"
    ];
  };

  home.stateVersion = "22.11";
}
