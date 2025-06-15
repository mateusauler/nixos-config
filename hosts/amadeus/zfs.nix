{ lib, pkgs, ... }:

{
  boot.supportedFilesystems.zfs = true;
  boot.zfs.extraPools = [ "tank" ];
  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
      pools = lib.mkForce [ ];
    };
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
    };
  };
  environment.systemPackages = with pkgs; [ zfstools ];
}
