{ inputs, config, lib, pkgs, ... }:

{
  imports = [ ../../home-manager-modules/base.nix ];

  modules = {
    gtk.enable = true;
    rofi.enable = true;
    librewolf.enable = true;
  };

  home.stateVersion = "22.11";
}