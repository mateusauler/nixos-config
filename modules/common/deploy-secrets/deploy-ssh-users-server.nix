{ config, lib, ... }:

let
  inherit (lib) foldlUsers;
  cfg = config.modules.deploy-secrets.ssh.users-server;
in
lib.mkIf cfg.enable {
  sops.secrets = foldlUsers config {
    fn =
      acc: name: user:
      acc
      // {
        "ssh-${name}-keys-server" = {
          sopsFile = ../../../users/${name}/id_server;
          format = "binary";
          owner = name;
          path = "${user.home}/.ssh/id_server";
        };
      };
  };

  home-manager.users = foldlUsers config {
    fn =
      acc: name: user:
      lib.recursiveUpdate acc {
        ${name} = {
          home.file."ssh_id_server.pub" = {
            target = ".ssh/id_server.pub";
            source = ../../../users/${name}/id_server.pub;
          };
          programs.git.extraConfig.core.sshCommand = "ssh -i ${user.home}/.ssh/id_server";
        };
      };
  };
}
