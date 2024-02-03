{ config, pkgs, lib, ... }:

let
  cfg = config.modules.virt-manager;

  inherit (lib) mkDefault;
in
{
  imports = [ ./nbd.nix ];

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

    users.groups.libvirtd = { };

    programs.virt-manager.enable = true;
  };
}
