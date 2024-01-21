{ config, lib, pkgs, ... }:

let
  cfg = config.modules.deploy-secrets.ssh.system;
  foldlKeyTypes = { acc ? { }, fn }: lib.foldl' fn acc [ "ed25519" "rsa" ];
in
lib.mkIf cfg.enable {
  sops.secrets =
    foldlKeyTypes {
      fn = (acc: k: acc // { "openssh/${k}" = { sopsFile = config.hostBaseDir + /secrets.yaml; }; });
    };

  environment.etc = foldlKeyTypes {
    fn = (acc: k:
      let
        key = "ssh_host_${k}_key.pub";
      in
      acc // {
        "ssh/${key}" = {
          source = config.hostBaseDir + /${key};
          mode = "0644";
        };
      });
  };

  systemd.services."deploy-system-ssh-keys" = {
    script = foldlKeyTypes {
      acc = "";
      fn = (acc: k:
        let
          secret-path = config.sops.secrets."openssh/${k}".path;
          ssh-key-path = "/etc/ssh/ssh_host_${k}_key";
        in
        acc +
        ''
          if [ -s "${secret-path}" ] ; then
            echo Deploying ${k}...
            cp ${secret-path} ${ssh-key-path}
            chown root:root ${ssh-key-path}
            chmod 0400 ${ssh-key-path}
            echo >> ${ssh-key-path}
          else
            echo Didn't deploy ${k}.
          fi
        '');
    };
    serviceConfig = {
      User = "root";
      WorkingDirectory = "/tmp";
    };
  };
}
