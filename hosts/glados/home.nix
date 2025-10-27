{ pkgs, ... }:

let
  module-names = [
    "steam-xdg"
  ];

  output-ports = {
    "1" = "DP-2";
    "2" = "HDMI-A-1";
  };
in
{
  modules = pkgs.lib.enableModules module-names {
    git.gpgKey = "82BE10715363265100DF88519AEA7E01F75F5E92";
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
