{
  config,
  lib,
  pkgs,
  ...
}:

let
  transmissionConfig = "${config.nixarr.transmission.stateDir}/.config/transmission-daemon/settings.json";
  transmissionService = config.systemd.services.transmission.name;

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
  sops.secrets.vpn-config.sopsFile = ./secrets.yaml;

  systemd = lib.mkIf (config.nixarr.transmission.vpn.enable) {
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
      enable = true;
      extraAllowedIps = [ "100.69.*" ];
      vpn.enable = true;
      flood.enable = true;
      extraSettings.rpc-host-whitelist = config.networking.hostName;
    };

    jellyfin.enable = true;
    jellyseerr.enable = true;
    radarr.enable = true;
    sonarr.enable = true;
    bazarr.enable = true;
    prowlarr.enable = true;
  };
}
