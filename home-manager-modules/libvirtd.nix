{ config, lib, ... }:

let
  cfg = config.modules.libvirtd;
in {
  options.modules.libvirtd.enable = lib.mkEnableOption "libvirtd";

  config = lib.mkIf cfg.enable {
    xdg.configFile."libvirt/qemu.conf".text = "nvram = [ \"/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd\" ]";
  };
}
