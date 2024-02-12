{ config, lib, pkgs, ... }:

let
  cfg = config.modules.distrobox;
in
{
  options.modules.distrobox.enable = lib.mkEnableOption "Distrobox";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.distrobox ];

    virtualisation.docker = {
      enable = true;
      rootless.enable = true;
    };

    # Enable rootless docker access
    users.groups.docker = { };
  };
}
