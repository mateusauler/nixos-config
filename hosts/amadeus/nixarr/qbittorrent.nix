{ config, pkgs, ... }:

let
  inherit (config.services) qbittorrent;
  port = qbittorrent.webuiPort;
  savePath = qbittorrent.serverConfig.BitTorrent.Session.DefaultSavePath;
in
{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    webuiPort = 8182;
    serverConfig = {
      BitTorrent = {
        MergeTrackersEnabled = true;
        Session = rec {
          AddExtensionToIncompleteFiles = true;
          AddTorrentToTopOfQueue = true;
          AnonymousModeEnabled = true;
          DefaultSavePath = "/tank/arr/media/qbittorrent";
          DisableAutoTMMByDefault = false;
          DisableAutoTMMTriggers = {
            CategoryChanged = false;
            CategorySavePathChanged = false;
            DefaultSavePathChanged = false;
          };
          MaxActiveCheckingTorrents = 5;
          MaxActiveDownloads = 5;
          MaxActiveTorrents = MaxActiveDownloads + MaxActiveUploads;
          MaxActiveUploads = 100;
          GlobalMaxRatio = 1.1;
          GlobalMaxInactiveSeedingMinutes = 1440;
          Preallocation = true;
          QueueingSystemEnabled = true;
          ReannounceWhenAddressChanged = true;
        };
      };
      Core.AutoDeleteAddedTorrentFile = "IfAdded";
      Preferences = {
        General.StatusbarExternalIPDisplayed = true;
        WebUI = {
          ReverseProxySupportEnabled = true;
          TrustedReverseProxiesList = "127.0.0.1";
        };
      };
    };
  };

  modules.proxy.services.qbittorrent = { inherit port; };

  systemd.tmpfiles.rules = [
    "d '${savePath}'             0755 ${qbittorrent.user} ${qbittorrent.group} - -"
    "d '${savePath}/.watch'      0755 ${qbittorrent.user} ${qbittorrent.group} - -"
    "d '${savePath}/radarr'      0755 ${qbittorrent.user} ${qbittorrent.group} - -"
    "d '${savePath}/sonarr'      0755 ${qbittorrent.user} ${qbittorrent.group} - -"
  ];

  sops.secrets.qbittorrent-password = {
    sopsFile = ../secrets.yaml;
    owner = qbittorrent.user;
  };

  systemd.timers.qbittorrent-clear-torrents = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Unit = config.systemd.services.qbittorrent-clear-torrents.name;
    };
  };

  systemd.services.qbittorrent = {
    serviceConfig.IOSchedulingPriority = 7;
    vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
    };
  };

  systemd.services.qbittorrent-clear-torrents = {
    requires = [ config.systemd.services.qbittorrent.name ];
    serviceConfig = {
      Type = "oneshot";
      User = qbittorrent.user;
      Group = qbittorrent.group;
    };
    path = with pkgs; [
      jq
      qbittorrent-cli
    ];
    script =
      let
        inherit (config.modules.proxy.services.qbittorrent) host;
        conn-args = ''
          --url http://${host}:${toString port} \
          --username qbittorrent \
          --password "$(cat ${config.sops.secrets.qbittorrent-password.path})"'';
      in
      # bash
      ''
        torrents=$(qbt torrent list ${conn-args} -F json | jq -r '.[] | select(.state == "pausedUP" and .category == "imported") | { name, hash }')
        if [[ -n $torrents ]]
        then
          echo Deleting:
          jq -r .name <<< $torrents
          jq -r .hash <<< $torrents | xargs qbt torrent delete --with-files ${conn-args}
        fi
      '';
  };

  vpnNamespaces.wg.portMappings = [
    {
      from = port;
      to = port;
    }
  ];

  services.nginx.virtualHosts."127.0.0.1:${toString port}" = {
    listen = [
      {
        addr = "0.0.0.0";
        port = port;
      }
    ];
    locations."/" = {
      recommendedProxySettings = true;
      proxyWebsockets = true;
      proxyPass = "http://192.168.15.1:${toString port}";
    };
  };
}
