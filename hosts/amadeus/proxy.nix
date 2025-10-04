{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.proxy;

  inherit (lib) mkOption mkEnableOption;
  inherit (lib.types)
    attrsOf
    enum
    int
    str
    submodule
    ;
  inherit (config.modules) dns;
in
{
  options.modules.proxy = {
    enable = mkEnableOption "Proxy module";
    services = mkOption {
      type = attrsOf (submodule {
        options = {
          host = mkOption {
            type = str;
            default = "${config.networking.hostName}";
          };
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
            }:
            lib.nameValuePair "${name}.${dns.baseDomain}" {
              sslCertificate = config.sops.secrets."ssl/cert".path;
              sslCertificateKey = config.sops.secrets."ssl/key".path;
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
