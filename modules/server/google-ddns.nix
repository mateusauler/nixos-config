{
  config,
  lib,
  pkgs,
  ...
}:

let
  service-name = "google-ddns";
  cfg = config.services.${service-name};
  description = "Google Domains DDNS update using Google's API";

  RuntimeDirectory = service-name;

  preStart = pkgs.writeShellScript "${service-name}-prestart" (
    lib.foldl (
      acc:
      {
        domain,
        usernameFile,
        passwordFile,
        ...
      }: # bash
      ''
        ${acc}
        install --mode=600 --owner=$USER ${passwordFile} /run/${RuntimeDirectory}/password-${domain}.key
        install --mode=600 --owner=$USER ${usernameFile} /run/${RuntimeDirectory}/username-${domain}.txt
      ''
    ) "" cfg.domains
  );

  script = pkgs.writeShellScript service-name (
    lib.foldl (
      acc:
      { domain, version, ... }: # bash
      ''
        ${acc}
        username=$(cat /run/${RuntimeDirectory}/username-${domain}.txt)
        password=$(cat /run/${RuntimeDirectory}/password-${domain}.key)
        auth="$(echo -n "$username:$password" | base64)"
        curl ${lib.optionalString (version != null) "--${version}"} \
          --request POST \
          --url "https://${cfg.endpoint}?hostname=${domain}" \
          --header "Authorization: Basic $auth"
      ''
    ) "" cfg.domains
  );

  inherit (lib) mkOption;
in
{
  options.services.${service-name} = with lib.types; {
    enable = lib.mkEnableOption description;
    domains = mkOption {
      type = listOf (submodule {
        options = {
          domain = mkOption { type = str; };
          usernameFile = mkOption { type = str; };
          passwordFile = mkOption { type = str; };
          version = mkOption {
            type = nullOr (enum [
              "ipv4"
              "ipv6"
            ]);
            default = null;
          };
        };
      });
    };
    interval = mkOption { default = "10min"; };
    endpoint = mkOption { default = "domains.google.com/nic/update"; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.${service-name} = {
      inherit description;
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      path = [
        pkgs.curl
        pkgs.coreutils
      ];
      serviceConfig = {
        DynamicUser = true;
        RuntimeDirectoryMode = "0700";
        StateDirectory = service-name;
        inherit RuntimeDirectory;
        Type = "oneshot";
        ExecStartPre = "!${preStart}";
        ExecStart = script;
      };
    };

    systemd.timers.${service-name} = {
      description = "Run ${service-name}";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = cfg.interval;
        OnUnitInactiveSec = cfg.interval;
      };
    };
  };
}
