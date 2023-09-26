{ inputs, config, lib, pkgs, ... }:

{
  imports = [ ../../home-manager-modules ];

  modules = {
    desktop.enable = true;
    hyprland.extraOptions = {
      "$mon1" = "DP-3";
      "$mon2" = "HDMI-A-1";
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
    git.gpgKey = "5D9269C32D1E49D278A4410C263716004E5EF18D";
    libvirtd.enable = true;
    steam-xdg.enable = true;
  };

  home.packages = with pkgs; [
    lutris
    heroic
    prismlauncher
  ];

  home.stateVersion = "22.11";
}
