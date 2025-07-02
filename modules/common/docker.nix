{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.docker;
in
{
  options.modules.docker.enable = lib.mkEnableOption "Docker";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.docker-credential-helpers ];
    virtualisation.docker = {
      enable = true;
      rootless.enable = true;
    };

    # Enable rootless docker access
    users.groups.docker = { };
  };
}
