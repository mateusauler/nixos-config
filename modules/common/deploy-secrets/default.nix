{ config, lib, ... }:

let
  cfg = config.modules.deploy-secrets;
in
{
  options.modules.deploy-secrets = {
    enable = lib.mkEnableOption "Secret provisioning with sops";
    gpg.enable = lib.mkTrueEnableOption "Deploy gpg keys using sops";
    ssh = {
      system.enable = lib.mkTrueEnableOption "Deploy system ssh keys using sops";
      users.enable = lib.mkTrueEnableOption "Deploy user ssh keys using sops";
      users-server.enable = lib.mkEnableOption "Deploy (server) user ssh keys using sops";
    };
  };

  imports = [
    ./deploy-gpg.nix
    ./deploy-ssh-users.nix
    ./deploy-ssh-users-server.nix
    ./deploy-ssh-system.nix
  ];

  config = lib.mkIf (!cfg.enable) {
    modules.deploy-secrets = {
      gpg.enable = lib.mkForce false;
      ssh.system.enable = lib.mkForce false;
      ssh.users.enable = lib.mkForce false;
      ssh.users-server.enable = lib.mkForce false;
    };
  };
}
