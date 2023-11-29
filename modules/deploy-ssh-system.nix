{ config, lib, pkgs, ... }:

let
  cfg = config.modules.deploy-ssh-system;
  forEachKeyType = { acc ? { }, fn }: lib.foldl' fn acc [ "ed25519" "rsa" ];
in
{
  options.modules.deploy-ssh-system.enable = lib.mkEnableOption "Deploy system ssh keys using sops";

  config = lib.mkIf cfg.enable {
    sops.secrets =
      forEachKeyType {
        fn = (acc: k: acc // { "openssh/${k}" = { sopsFile = ../hosts/${config.networking.hostName}/secrets.yaml; }; });
      };

    environment.etc = forEachKeyType {
      fn = (acc: k:
        let
          key = "ssh_host_${k}_key.pub";
        in
        acc // {
          "ssh/${key}" = {
            source = ../hosts/${config.networking.hostName} + "/${key}";
            mode = "0644";
          };
        });
    };

    systemd.services."deploy-system-ssh-keys" = {
      script = forEachKeyType {
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
  };
}
