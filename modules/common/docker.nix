{ config, lib, pkgs, ... }:

let
  cfg = config.modules.docker;
in
{
  options.modules.docker.enable = lib.mkEnableOption "Docker";

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      rootless.enable = true;
    };

    # Enable rootless docker access
    users.groups.docker = { };
  };
}
