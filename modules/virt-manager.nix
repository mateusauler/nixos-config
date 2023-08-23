{ config, custom, pkgs, lib, ... }:

let
  inherit (custom) username;
  inherit (lib) mkDefault;
  cfg = config.modules.virt-manager;
in {
  options.modules.virt-manager.enable = lib.mkEnableOption "virt-manager";

  config = lib.mkIf cfg.enable {
    virtualisation = {
      spiceUSBRedirection.enable = mkDefault true;
      libvirtd = {
        enable = true;
        onBoot = mkDefault "ignore";
        qemu.runAsRoot = mkDefault false;
      };
    };

    users.users.${username}.extraGroups = [ "libvirtd" ];

    environment.systemPackages = [ pkgs.virt-manager ];
  };
}
