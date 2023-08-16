{ inputs, config, lib, pkgs, ... }:

{
  imports = [ ../../home-manager-modules/base.nix ];

  modules = {
    desktop.enable = true;
    hyprland.monitors = {
      "$mon1" = "HDMI-A-1";
      "$mon2" = "DVI-D-1";
      "$mon3" = "$mon2";

      # monitor = name,resolution,position,scale
      monitor = [
        "$mon1,prefered,1920x0,auto"
        "$mon2,prefered,0x0,auto"
      ];

      workspace = [
        "1, monitor:$mon1"
        "2, monitor:$mon1"
        "3, monitor:$mon1"
        "4, monitor:$mon3"
        "5, monitor:$mon2"
        "10, monitor:$mon2"
      ];
    };
    git.gpgKey = "202F1FFC3620EDD81E4C9F93CC20C1FD21A77FB0";
  };

  home.stateVersion = "22.11";
}