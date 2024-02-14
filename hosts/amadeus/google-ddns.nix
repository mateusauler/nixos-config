{ config, ... }:

{
  sops.secrets = {
    "ddns/password".sopsFile = ./secrets.yaml;
    "ddns/username".sopsFile = ./secrets.yaml;
    "ddns/domain" = {
      sopsFile = ./secrets.yaml;
      mode = "0644";
    };
  };

  services.google-ddns.domains = [
    {
      domain = "$(cat ${config.sops.secrets."ddns/domain".path})";
      usernameFile = config.sops.secrets."ddns/username".path;
      passwordFile = config.sops.secrets."ddns/password".path;
    }
  ];
}
