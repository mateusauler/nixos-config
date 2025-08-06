{ lib, pkgs, ... }:

let
  module-names = [
    "desktop"
    "efi"
    "gaming"
    "virt-manager"
    "syncthing"
    "zswap"
  ];
in
{
  imports = [ ./hardware-configuration.nix ];

  modules = lib.enableModules module-names { };

  enabledUsers = [ "mateus" ];

  networking.hostName = "glados";

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };

  environment.systemPackages = with pkgs; [
    lact
    refind
  ];

  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];

  system.stateVersion = "22.11";
}
