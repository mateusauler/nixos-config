{ config, lib, pkgs, ... }:

let
  foldlUsers = pkgs.lib.foldlUsers config;
  foldlKeyTypes = { acc ? { }, fn }: lib.foldl' fn acc [ "ed25519" "rsa" ];
  foldlUsersKeys = f: foldlUsers config { fn = acc: name: user: acc // foldlKeyTypes { fn = acc: f acc name user; }; };
  cfg = config.modules.deploy-secrets;
in
{
  options.modules.deploy-secrets = {
    enable = lib.mkEnableOption "Secret provisioning with sops";
    gpg.enable = pkgs.lib.mkTrueEnableOption "Deploy gpg keys using sops";
    ssh = {
      system.enable = pkgs.lib.mkTrueEnableOption "Deploy system ssh keys using sops";
      users.enable = pkgs.lib.mkTrueEnableOption "Deploy user ssh keys using sops";
    };
  };

  imports = [
    ./deploy-gpg.nix
    ./deploy-ssh-users.nix
    ./deploy-ssh-system.nix
  ];

  config = lib.mkIf (!cfg.enable) {
    modules.deploy-secrets = {
      gpg.enable = lib.mkForce false;
      ssh.system.enable = lib.mkForce false;
      ssh.users.enable = lib.mkForce false;
    };
  };
}
