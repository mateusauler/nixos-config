{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.pipewire;
  inherit (lib) mkDefault;
in
{
  options.modules.pipewire.enable = lib.mkEnableOption "desktop";

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = mkDefault true;
      alsa = {
        enable = mkDefault true;
        support32Bit = mkDefault true;
      };
      pulse.enable = mkDefault true;
      jack.enable = mkDefault true;

      wireplumber = {
        enable = true;
        configPackages = [
          # https://wiki.archlinux.org/title/PipeWire#Audio_cutting_out_when_multiple_streams_start_playing
          (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/50-alsa-config.conf" ''
            monitor.alsa.rules = [
              {
                matches = [
                  {
                    node.name = "~alsa_output.*"
                  }
                ]
                actions = {
                  update-props = {
                    api.alsa.period-size = 1024
                    api.alsa.headroom    = 8192
                  }
                }
              }
            ]
          '')
        ];
      };
    };
    # https://wiki.archlinux.org/title/PipeWire#Missing_realtime_priority/crackling_under_load_after_suspend
    systemd.services.rtkit-daemon = {
      overrideStrategy = "asDropin";
      serviceConfig.ExecStart = [
        ""
        "${pkgs.rtkit}/libexec/rtkit-daemon --no-canary"
      ];
    };
  };
}
