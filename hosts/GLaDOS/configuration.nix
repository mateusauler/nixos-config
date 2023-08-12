{ config, pkgs, custom, ... }:

let username = custom.username;
in {
  imports = [ ./hardware-configuration.nix ../../generic/efi.nix ../../generic/desktop.nix ../../generic/openssh.nix ];

  networking.hostName = "GLaDOS";

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt";
  };

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    lutris
    prismlauncher
  ];

  system.stateVersion = "22.11";
}

