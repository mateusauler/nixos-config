{ pkgs, custom, ... }:

let
  inherit (custom) username;
  module-names  = [ "desktop" "efi" "openssh" "virt-manager" ];
in {
  imports = [ ./hardware-configuration.nix ../../modules ];

  modules = pkgs.lib.my.enableModules { inherit module-names; };

  networking.hostName = "GLaDOS";

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    lutris
    heroic
    prismlauncher
  ];

  system.stateVersion = "22.11";
}

