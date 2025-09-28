{ config, lib, ... }:

let
  cfg = config.modules.proxy;

  inherit (lib) mkOption mkEnableOption;
  inherit (lib.types)
    attrsOf
    enum
    int
    submodule
    ;

  mkReadOnly =
    value:
    mkOption {
      default = value;
      readOnly = true;
    };
in
{
  options.modules.proxy = {
    enable = mkEnableOption "Proxy module";
    netbirdIP = mkReadOnly "100.69.71.75";
    baseDomain = mkReadOnly "auler.dev";
    hostDomain = mkReadOnly "${config.networking.hostName}.${cfg.baseDomain}";
    services = mkOption {
      type = attrsOf (submodule {
        options = {
          port = mkOption { type = int; };
          protocol = mkOption {
            type = enum [
              "http"
              "https"
            ];
            default = "http";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    sops.secrets = {
      "ssl/cert" = {
        sopsFile = config.hostBaseDir + "/secrets.yaml";
        owner = "nginx";
      };
      "ssl/key" = {
        sopsFile = config.hostBaseDir + "/secrets.yaml";
        owner = "nginx";
      };
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      virtualHosts =
        let
          genVhost =
            name:
            {
              port,
              protocol,
            }:
            lib.nameValuePair "${name}.${cfg.baseDomain}" {
              sslCertificate = config.sops.secrets."ssl/cert".path;
              sslCertificateKey = config.sops.secrets."ssl/key".path;
              addSSL = true;
              locations."/" = {
                proxyPass = "${protocol}://localhost:${toString port}";
                proxyWebsockets = true;
              };
            };
        in
        lib.mapAttrs' genVhost cfg.services;
    };

    containers.pihole.config =
      { ... }:
      {
        services.pihole-ftl.settings.dns = {
          hosts = [ "${cfg.netbirdIP} ${cfg.hostDomain}" ];
          cnameRecords =
            cfg.services |> builtins.attrNames |> map (n: "${n}.${cfg.baseDomain},${cfg.hostDomain}");
        };
      };
  };
}
