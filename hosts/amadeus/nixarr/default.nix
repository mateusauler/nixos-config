{
  config,
  lib,
  pkgs,
  ...
}:

let
  transmissionConfig = "${config.nixarr.transmission.stateDir}/.config/transmission-daemon/settings.json";
  transmissionService = config.systemd.services.transmission.name;

  inherit (config.modules) proxy dns;
  inherit (proxy) services;
  inherit (config) nixarr;

  awk = "${pkgs.gawk}/bin/awk";
  jq = lib.getExe pkgs.jq;
  natpmpc = lib.getExe pkgs.libnatpmp;
  sponge = "${pkgs.moreutils}/bin/sponge";

  updatePortsAndRunCommandIfChanged = command: ''
    set -euo pipefail

    port_before=$(${jq} -r '."peer-port"' "${transmissionConfig}")

    ${natpmpc} -a 1 0 tcp 60 -g 10.2.0.1
    result=$(${natpmpc} -a 1 0 udp 60 -g 10.2.0.1)

    port=$(grep 'Mapped public port' <<< "$result" | head -n 1 | ${awk} '{print $4}')

    if [[ $port -ne $port_before ]]
    then
      ${command}
    fi
  '';
in
{
  imports = [
    ./qbittorrent.nix
  ];

  sops.secrets.vpn-config.sopsFile = ../secrets.yaml;

  systemd = lib.mkIf (nixarr.transmission.enable && nixarr.transmission.vpn.enable) {
    services.protonvpn-port-updater = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      script = updatePortsAndRunCommandIfChanged ''systemctl restart "${transmissionService}"'';
      serviceConfig.Type = "oneshot";
      vpnConfinement = {
        enable = true;
        vpnNamespace = "wg";
      };
    };
    timers.protonvpn-port-updater = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnUnitActiveSec = "30s";
        AccuracySec = "1s";
        Unit = config.systemd.services.protonvpn-port-updater.name;
      };
    };
    services.transmission.serviceConfig.ExecStartPre = [
      (pkgs.writeShellScript "transmission-set-peer-port" (updatePortsAndRunCommandIfChanged ''
        echo "Updating transmission peer port from $port_before to $port."
        ${jq} --argjson p "$port" '."peer-port" = $p' "${transmissionConfig}" | ${sponge} "${transmissionConfig}"
      ''))
    ];
  };

  modules.proxy.services = {
    bazarr.port = nixarr.bazarr.port;
    jellyfin = {
      port = 8096;
      externalPorts = [
        {
          port = 8920;
          ssl = true;
        }
      ];
    };
    jellyseerr.port = 5055;
    prowlarr.port = nixarr.prowlarr.port;
    radarr.port = nixarr.radarr.port;
    sonarr.port = 8989;
    transmission = lib.mkIf nixarr.transmission.enable { port = nixarr.transmission.uiPort; };
  };

  nixarr = {
    enable = true;

    mediaDir = "/tank/arr/media";
    stateDir = "/tank/arr/media/.state/nixarr";

    vpn = {
      enable = true;
      wgConf = config.sops.secrets.vpn-config.path;
      accessibleFrom = [ "100.69.0.0/16" ];
    };

    transmission = {
      enable = false;
      extraAllowedIps = [ "100.69.*" ];
      vpn.enable = true;
      flood.enable = true;
      extraSettings = {
        download-queue-enabled = true;
        download-queue-size = 5;
        ratio-limit-enabled = true;
        ratio-limit = 3;
        rpc-host-whitelist = "${config.networking.hostName},transmission.${dns.baseDomain}";
        utp-enabled = true;
      };
    };

    recyclarr = {
      enable = true;
      configFile = pkgs.writeText "recyclarr-config" ''
        radarr:
          movies:
            api_key: !env_var RADARR_API_KEY
            base_url: http://localhost:${toString services.radarr.port}
            quality_definition:
              type: movie
        sonarr:
          series:
            api_key: !env_var SONARR_API_KEY
            base_url: http://localhost:${toString services.sonarr.port}
            quality_definition:
              type: series
      '';
    };

    jellyfin.enable = true;
    jellyseerr.enable = true;
    radarr.enable = true;
    sonarr.enable = true;
    bazarr.enable = true;
    prowlarr.enable = true;
  };
}
