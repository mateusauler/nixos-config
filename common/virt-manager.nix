{ config, custom, pkgs, ... }:

let
  inherit (custom) username;
in {
  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu.runAsRoot = false;
    };
  };

  users.users.${username}.extraGroups = [ "libvirtd" ];

  environment.systemPackages = [ pkgs.virt-manager ];
}
