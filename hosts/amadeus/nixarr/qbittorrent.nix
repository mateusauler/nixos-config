{ config, ... }:

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
        Session = {
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
          MaxActiveTorrents = 35;
          MaxActiveUploads = 30;
          GlobalMaxRatio = 1.1;
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

  systemd.services.qbittorrent = {
    serviceConfig.IOSchedulingPriority = 7;
    vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
    };
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
