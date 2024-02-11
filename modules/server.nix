{ config, lib, pkgs, ... }:

let
  cfg = config.modules.server;
in
{
  options.modules.server.enable = lib.mkEnableOption "server";

  config = lib.mkIf cfg.enable {
    users.users = lib.foldl' (acc: u: acc // { ${u}.hashedPasswordFile = null; }) { } config.enabledUsers;

    # Use stable kernel
    boot.kernelPackages = pkgs.linuxPackages;

    security.sudo = {
      wheelNeedsPassword = false;
    };

    modules.deploy-secrets = {
      gpg.enable = false;
      ssh.users.enable = false;
    };
  };
}
