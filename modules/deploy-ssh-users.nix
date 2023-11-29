{ config, lib, pkgs, ... }:

let
  foldlKeyTypes = { acc ? { }, fn }: lib.foldl' fn acc [ "ed25519" "rsa" ];
  foldlUsersKeys = f: pkgs.lib.foldlUsers config { fn = acc: name: user: acc // foldlKeyTypes { fn = acc: f acc name user; }; };
  cfg = config.modules.deploy-ssh-users;
in
{
  options.modules.deploy-ssh-users.enable = lib.mkEnableOption "Deploy user ssh keys using sops";

  config = lib.mkIf cfg.enable {
    sops.secrets = foldlUsersKeys (acc: name: user: k: acc // {
      "ssh/${name}/keys/${k}" = {
        sopsFile = ../users/secrets.yaml;
        owner = name;
        path = "${user.home}/.ssh/id_${k}";
      };
    });

    home-manager.users = foldlUsersKeys (acc: name: _: k: lib.recursiveUpdate acc {
      ${name}.home.file."ssh_id_${k}.pub" = {
        target = ".ssh/id_${k}.pub";
        source = ../users + "/${name}/id_${k}.pub";
      };
    });
  };
}
