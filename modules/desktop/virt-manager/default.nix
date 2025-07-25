{
  config,
  pkgs,
  lib,
  ...
}:

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
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = mkDefault false;
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [ pkgs.OVMFFull.fd ];
          };
        };
      };
    };

    networking.firewall = {
      allowedTCPPortRanges = [
        # spice
        {
          from = 5900;
          to = 5999;
        }
      ];
      allowedTCPPorts = [
        # libvirt
        16509
      ];
    };

    environment.systemPackages = [ pkgs.virtiofsd ];

    users.groups.libvirtd = { };

    programs.virt-manager.enable = true;
  };
}
