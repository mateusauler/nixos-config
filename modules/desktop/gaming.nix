{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.gaming;
in
{
  options.modules.gaming.enable = lib.mkEnableOption "Gaming";

  config = lib.mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Gaming#Tweaking_kernel_parameters_for_response_time_consistency

    boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642; # https://wiki.archlinux.org/title/Gaming#Game_compatibility

      "vm.compaction_proactiveness" = 0;
      "vm.min_free_kbytes" = 1048576;
      "vm.page_lock_unfairness" = 1;
      "vm.swappiness" = 10;
      "vm.watermark_boost_factor" = 1;
      "vm.watermark_scale_factor" = 500;
      "vm.zone_reclaim_mode" = 0;
    };

    systemd.services.enable-lru-gen = {
      description = "Enable LRU Generations";
      script = # bash
        ''
          echo 5 > /sys/kernel/mm/lru_gen/enabled
        '';
      wantedBy = [ "multi-user.target" ];
      after = [ "sys-fsremount-root.service" ];
    };

    environment.systemPackages = with pkgs; [
      lutris
      heroic
      prismlauncher
    ];
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
  };
}
