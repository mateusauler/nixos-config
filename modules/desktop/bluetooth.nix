{ config, lib, pkgs, ... }:

let
  cfg = config.modules.bluetooth;
in
{
  options.modules.bluetooth.enable = lib.mkEnableOption "Bluetooth";

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };
    services.blueman.enable = true;
  };
}
