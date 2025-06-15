{ config, lib, ... }:

let
  cfg = config.modules.syncthing;
in
{
  options.modules.syncthing.enable = lib.mkEnableOption "Syncthing";

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "syncthing/cert".sopsFile = config.hostBaseDir + "/secrets.yaml";
      "syncthing/key".sopsFile = config.hostBaseDir + "/secrets.yaml";
    };

    services.syncthing = {
      enable = true;
      cert = config.sops.secrets."syncthing/cert".path;
      key = config.sops.secrets."syncthing/key".path;
      openDefaultPorts = true;
      overrideDevices = false;
      overrideFolders = false;
      settings.options.urAccepted = -1;
    };

    boot.kernel.sysctl."fs.inotify.max_user_watches" = 20000000;
  };
}
