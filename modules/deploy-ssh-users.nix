{ config, lib, pkgs, ... }:

let
  foldlUsers = pkgs.lib.foldlUsers config;
  forEachKeyType = { acc ? { }, fn }: lib.foldl' fn acc [ "ed25519" "rsa" ];
  cfg = config.modules.deploy-ssh-users;
in
{
  options.modules.deploy-ssh-users.enable = lib.mkEnableOption "Deploy user ssh keys using sops";

  config = lib.mkIf cfg.enable {
    sops.secrets = foldlUsers {
      fn = acc: name: _: acc // forEachKeyType {
        fn = acc: k: acc // {
          "ssh/${name}/keys/${k}" = {
            sopsFile = ../users/secrets.yaml;
            owner = name;
          };
        };
      };
    };

    systemd.user.services = foldlUsers {
      fn = acc: name: user: acc // {
        "deploy-ssh-keys-${name}" = {
          script = forEachKeyType {
            acc = "";
            fn = acc: k:
              let
                secret-path = config.sops.secrets."ssh/${name}/keys/${k}".path;
              in
              acc +
                ''
                  if [ -s "${secret-path}" ] ; then
                    echo Deploying ${k}...

                    # Import the key
                    mkdir -p ${user.home}/.ssh
                    cp ${../users/${name}/id_${k}.pub} ${user.home}/.ssh/id_${k}.pub
                    cp "${secret-path}" ${user.home}/.ssh/id_${k}

                    echo Finished
                  else
                    echo Didn\'t deploy ${k}
                  fi
                '';
          };
          wantedBy = [ "multi-user.target" ];
        };
      };
    };
  };
}
