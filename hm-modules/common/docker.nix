{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.docker;
  jsonFormat = pkgs.formats.json { };
in
{
  options.modules.docker = {
    enable = pkgs.lib.mkEnableOption "docker";
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
  };
}
