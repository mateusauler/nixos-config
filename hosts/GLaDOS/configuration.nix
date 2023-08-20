{ pkgs, custom, ... }:

let
  inherit (custom) username;
in {
  imports = [ ./hardware-configuration.nix ../../common ];

  modules = {
    desktop.enable = true;
    efi.enable = true;
    virt-manager.enable = true;
  };

  networking.hostName = "GLaDOS";

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    lutris
    heroic
    prismlauncher
  ];

  system.stateVersion = "22.11";
}

