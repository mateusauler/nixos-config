{ config, pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };

  environment.systemPackages = with pkgs; [
    efibootmgr
    refind
  ];
}