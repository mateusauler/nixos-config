{ pkgs, custom, ... }:

let
  inherit (custom) username;
in {
  imports = [
    ./hardware-configuration.nix
    ../../common/efi.nix
    ../../common/desktop.nix
    ../../common/openssh.nix
    ../../common/virt-manager.nix
  ];

  networking.hostName = "GLaDOS";

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    lutris
    heroic
    prismlauncher
  ];

  system.stateVersion = "22.11";
}

