{ config, ... }:

{
  sops.secrets = {
    "ddns/password".sopsFile = ./secrets.yaml;
    "ddns/username".sopsFile = ./secrets.yaml;
  };

  services.google-ddns.domains = [
    {
      domain = "amadeus.auler.dev";
      usernameFile = config.sops.secrets."ddns/username".path;
      passwordFile = config.sops.secrets."ddns/password".path;
      version = "ipv6";
    }
  ];
}
