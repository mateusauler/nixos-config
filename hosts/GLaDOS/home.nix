{ inputs, config, lib, pkgs, ... }:

{
  imports = [ ../../home-manager-modules/base.nix ];

  modules = {
    desktop.enable = true;
  };

  home.stateVersion = "22.11";
}