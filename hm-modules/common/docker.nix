{
  config,
  lib,
  nixosConfig,
  pkgs,
  ...
}:

let
  cfg = config.modules.docker;
  jsonFormat = pkgs.formats.json { };
in
{
  options.modules.docker = {
    enable = pkgs.lib.mkEnableOption "docker" // { default = nixosConfig.modules.docker.enable; };
    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."docker/config.json".source = jsonFormat.generate "docker-config" cfg.settings;
    modules.docker.settings = {
      # Docker Hub authentication
      auths = {
        "https://index.docker.io/v1/" = { };
        "https://index.docker.io/v1/access-token" = { };
        "https://index.docker.io/v1/refresh-token" = { };
      };
      credsStore = "secretservice";
    };
    programs.fish.shellAbbrs = {
      dc = "docker compose";

      dca = "docker compose attach";
      dcb = "docker compose build";
      dcc = "docker compose create";
      dcd = "docker compose down";
      dcl = "docker compose logs";
      dclf = "docker compose logs -f";
      dcr = "docker compose run --rm";
      dcs = "docker compose stop";
      dcu = "docker compose up";
    };
  };
}
