{ inputs, config, lib, pkgs, ... }:

{
  imports = [ ../../home-manager-modules/base.nix ];

  modules = {
    rofi.enable = true;
  };

  home.stateVersion = "22.11";
}