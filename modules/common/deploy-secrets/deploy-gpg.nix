{
  config,
  lib,
  pkgs,
  ...
}:

let
  foldlUsers = lib.foldlUsers config;
  cfg = config.modules.deploy-secrets.gpg;
in
lib.mkIf cfg.enable {
  sops.secrets = foldlUsers {
    fn =
      acc: name: _:
      acc
      // {
        "gpg-${name}-keys" = {
          key = "gpg/keys";
          sopsFile = ../../../users/${name}/secrets.yaml;
          owner = name;
        };
        "gpg-${name}-password" = {
          key = "gpg/password";
          sopsFile = ../../../users/${name}/secrets.yaml;
          owner = name;
        };
      };
  };

  systemd.user.services = foldlUsers {
    fn =
      acc: name: _:
      acc
      // {
        "deploy-gpg-keys-${name}" = {
          script =
            let
              secret-path = config.sops.secrets."gpg-${name}-keys".path;
              password-path = config.sops.secrets."gpg-${name}-password".path;
              sort-list = list: ''($(printf "%s\n" "''${${list}[@]}" | sort))'';
              getSecretKeyIDs = "$(gpg --list-secret-keys --keyid-format LONG | awk '/sec/{if (match($0, /([0-9A-F]{16,})/, m)) print m[1]}')";
            in
            # bash
            ''
              mkdir -p "$GNUPGHOME" -m "0700"

              if [ -s "${secret-path}" ] ; then
                echo Deploying GPG...

                # Private keys that existed before importing
                previousSecretKeys=${getSecretKeyIDs}
                previousSecretKeys=${sort-list "previousSecretKeys"}

                # Import the keys
                gpg --batch --import ${secret-path}

                if [ -s "${password-path}" ] ; then
                  echo Setting gpg password...

                  # Private keys that exist now
                  currentSecretKeys=${getSecretKeyIDs}
                  currentSecretKeys=${sort-list "currentSecretKeys"}

                  # The difference of the two lists are the newly imported keys
                  newKeys=$(comm -3 <(printf "%s\n" "''${previousSecretKeys[@]}") <(printf "%s\n" "''${currentSecretKeys[@]}"))

                  # Set the password for each key
                  for key in ''${newKeys[@]}
                  do
                    cat "${password-path}" | gpg --batch --passphrase-fd 0 --pinentry-mode loopback --edit-key $key passwd quit
                  done
                fi

                echo Finished
              else
                echo Didn\'t deploy GPG.
              fi
            '';
          wantedBy = [ "default.target" ];
          environment = {
            GNUPGHOME = config.home-manager.users.${name}.home.sessionVariables.GNUPGHOME or "";
          };
          path = with pkgs; [
            coreutils
            gawk
            gnupg
          ];
        };
      };
  };
}
