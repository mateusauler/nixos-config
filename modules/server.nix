{ config, lib, pkgs, ... }:

let
  cfg = config.modules.server;
in
{
  options.modules.server.enable = lib.mkEnableOption "server";

  config = lib.mkIf cfg.enable {
    # Use stable kernel
    boot.kernelPackages = pkgs.linuxPackages;

    security.sudo = {
      wheelNeedsPassword = false;
      # FIXME: This should allow for password-less sudo when rebuilding the system. But it does not work.
      # extraRules =
      #   let
      #     storePrefix = "/nix/store/*";
      #     systemName = "nixos-system-${config.networking.hostName}-*";
      #   in
      #   [
      #     {
      #       commands = [
      #         {
      #           command = "${storePrefix}-nix-*/bin/nix-env -p /nix/var/nix/profiles/system --set ${storePrefix}-${systemName}";
      #           options = [ "NOPASSWD" ];
      #         }
      #         {
      #           command = "${storePrefix}-${systemName}/bin/switch-to-configuration";
      #           options = [ "NOPASSWD" ];
      #         }
      #       ];
      #       groups = [ "wheel" ];
      #     }
      #   ];
    };

    modules.deploy-secrets = {
      gpg.enable = false;
      ssh.users.enable = false;
      ssh.users-server.enable = true;
    };
  };
}
