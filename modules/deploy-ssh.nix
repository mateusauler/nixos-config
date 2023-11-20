{ config, lib, pkgs, ... }:

let
  cfg = config.modules.deploy-ssh;
in
{
  options.modules.deploy-ssh.enable = lib.mkEnableOption "Deploy ssh keys using sops";

  config = lib.mkIf cfg.enable {
    sops.secrets =
      let
        sopsFile = ../hosts/${config.networking.hostName}/secrets.yaml;
      in
      {
        "openssh/rsa" = { inherit sopsFile; };
        "openssh/ed25519" = { inherit sopsFile; };
      };

    systemd.services."deploy-ssh-keys" = {
      script =
        lib.foldl'
          (acc: k:
            let
              secret-path = config.sops.secrets."openssh/${k}".path;
              ssh-key-path = "/etc/ssh/ssh_host_${k}_key";
            in
            acc +
            ''
              if [ -f "${secret-path}" ] && [ ! -z "$(cat ${secret-path})" ] ; then
                echo Deploying ${k}...
                cp ${secret-path} ${ssh-key-path}
                chown root:root ${ssh-key-path}
                chmod 0400 ${ssh-key-path}
                echo >> ${ssh-key-path}
              else
                echo Didn't deploy ${k}.
              fi
            '')
          ""
          [ "ed25519" "rsa" ];
      serviceConfig = {
        User = "root";
        WorkingDirectory = "/tmp";
      };
    };
  };
}
