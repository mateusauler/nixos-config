{ config, lib, ... }:

let
  foldlKeyTypes =
    {
      acc ? { },
      fn,
    }:
    lib.foldl' fn acc [
      "ed25519"
      "rsa"
    ];

  foldlUsersKeys =
    f:
    lib.foldlUsers config {
      fn =
        acc: name: user:
        acc // foldlKeyTypes { fn = acc: f acc name user; };
    };

  cfg = config.modules.deploy-secrets.ssh.users;
in
lib.mkIf cfg.enable {
  sops.secrets = foldlUsersKeys (
    acc: name: user: k:
    acc
    // {
      "ssh-${name}-keys-${k}" = {
        sopsFile = ../../../users/${name}/secrets.yaml;
        key = "ssh/keys/${k}";
        owner = name;
      };
    }
  );

  # TODO: Turn this into a home-manager activation script
  systemd.services = foldlUsersKeys (
    acc: name: user: k:
    acc
    // {
      "deploy-${name}-ssh-key-${k}" = {
        script =
          let
            ssh-sec-key-source = config.sops.secrets."ssh-${name}-keys-${k}".path;
            ssh-pub-key-source = ../../../users + "/${name}/id_${k}.pub";

            ssh-sec-key-target = "${user.home}/.ssh/id_${k}";
            ssh-pub-key-target = "${ssh-sec-key-target}.pub";
          in
          ''
            if [[ -s "${ssh-sec-key-source}" ]] ; then
              echo Deploying "${k}"...
              cp "${ssh-sec-key-source}" "${ssh-sec-key-target}"
              chown ${name}:${user.group} "${ssh-sec-key-target}"
              chmod 0400 "${ssh-sec-key-target}"
              echo >> "${ssh-sec-key-target}"

              cp "${ssh-pub-key-source}" "${ssh-pub-key-target}"
              chown ${name}:${user.group} "${ssh-pub-key-target}"
              chmod 0644 "${ssh-pub-key-target}"
              echo >> "${ssh-pub-key-target}"
            else
              echo "Didn't deploy ${k}".
            fi
          '';
        serviceConfig = {
          User = "root";
          WorkingDirectory = "/tmp";
        };
      };
    }
  );
}
