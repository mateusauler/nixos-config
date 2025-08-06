{ pkgs, ... }:

let
  module-names = [
    "libvirtd"
    "steam-xdg"
    "smm"
  ];

  output-ports = {
    "1" = "DP-2";
    "2" = "HDMI-A-1";
  };
in
{
  modules = pkgs.lib.enableModules module-names {
    git.gpgKey = "A09DC0933C374BFC2B5A269F80A5D62F6EB7D9F0";
    niri.outputs = {
      "1" = {
        focus-at-startup = true;
        variable-refresh-rate = true;
        position = {
          x = 0;
          y = 0;
        };
        name = output-ports."1";
      };
      "2" = {
        position = {
          x = -1920;
          y = 360;
        };
        name = output-ports."2";
      };
    };
  };

  wayland.windowManager.hyprland.settings = {
    "$mon1" = output-ports."1";
    "$mon2" = output-ports."2";

    # monitor = name,resolution,position,scale
    monitor = [
      "$mon1,prefered,1920x0,auto"
      "$mon2,prefered,0x360,auto"
    ];

    workspace = [
      "1, monitor:$mon1"
      "2, monitor:$mon1"
      "3, monitor:$mon3"
      "4, monitor:$mon2"
      "5, monitor:$mon2"
    ];
  };

  home.stateVersion = "22.11";
}
