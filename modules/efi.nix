{ pkgs, options, config, lib, ... }:

let
  inherit (lib) mkDefault;
  cfg = config.modules.efi;
in {
  options.modules.efi.enable = lib.mkEnableOption "efi";

  config = lib.mkIf cfg.enable {
    boot.loader = {
      systemd-boot.enable = mkDefault true;
      efi.canTouchEfiVariables = mkDefault true;
      timeout = mkDefault 0;
    };

    environment.systemPackages = with pkgs; [
      efibootmgr
      refind
    ];
  };
}
