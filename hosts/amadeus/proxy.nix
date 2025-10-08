{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.proxy;

  inherit (lib) mkOption mkEnableOption;
  inherit (lib.types)
    attrsOf
    enum
    int
    listOf
    str
    submodule
    ;
  inherit (config.modules) dns;
in
{
  options.modules.proxy = {
    enable = mkEnableOption "Proxy module";
    services = mkOption {
      type =
        attrsOf
        <| submodule {
          options = {
            host = mkOption {
              type = str;
              default = "${config.networking.hostName}";
            };
            port = mkOption { type = int; };
            externalPorts = mkOption {
              type =
                listOf
                <| submodule {
                  options = {
                    port = mkOption { type = int; };
                    ssl = mkOption { default = false; };
                  };
                };
              default = [ ];
            };
            protocol = mkOption {
              type = enum [
                "http"
                "https"
              ];
              default = "http";
            };
          };
        };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    networking.firewall.allowedUDPPorts = [
      443 # QUIC
    ];

    modules.dns.records = cfg.services |> builtins.mapAttrs (_: _: { });

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
      package = pkgs.nginxQuic;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      virtualHosts =
        let
          genVhost =
            name:
            {
              host,
              port,
              protocol,
              externalPorts,
            }:
            lib.nameValuePair "${name}.${dns.baseDomain}" {
              listen =
                externalPorts
                ++ [
                  {
                    port = 443;
                    ssl = true;
                  }
                  {
                    port = 80;
                    ssl = false;
                  }
                ]
                |> map (e: [
                  (e // { addr = "0.0.0.0"; })
                  (e // { addr = "[::0]"; })
                ])
                |> lib.flatten;
              sslCertificate = config.sops.secrets."ssl/cert".path;
              sslCertificateKey = config.sops.secrets."ssl/key".path;
              quic = true;
              addSSL = true;
              locations."/" = {
                proxyPass = "${protocol}://${host}:${toString port}";
                proxyWebsockets = true;
              };
            };
        in
        lib.mapAttrs' genVhost cfg.services;
    };
  };
}
