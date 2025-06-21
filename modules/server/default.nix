{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.server;
in
{
  options.modules.server.enable = lib.mkEnableOption "server";

  config = lib.mkIf cfg.enable {
    # Use stable kernel
    boot.kernelPackages = pkgs.linuxPackages;

    # Allow passwordless remote rebuild
    security.sudo.extraRules =
      let
        storePrefix = "/nix/store/*";
        systemName = "${storePrefix}-nixos-system-${config.networking.hostName}-*";
      in
      [
        {
          commands = [
            {
              command = "${storePrefix}/bin/nix-env -p /nix/var/nix/profiles/system --set ${systemName}";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${storePrefix}/bin/systemd-run * --unit=nixos-rebuild-switch-to-configuration *";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${storePrefix}/bin/env * ${systemName}/bin/switch-to-configuration *";
              options = [ "NOPASSWD" ];
            }
          ];
          groups = [ "wheel" ];
        }
      ];

    modules.deploy-secrets = {
      gpg.enable = false;
      ssh.users.enable = false;
      ssh.users-server.enable = true;
    };
  };
}
