{ config, lib, pkgs, ... }:

let
  cfg = config.modules.battery;
in
{
  options.modules.battery = {
    enable = lib.mkEnableOption "Battery";
    intel = lib.mkOption { default = false; };
  };

  config = lib.mkIf cfg.enable {
    # Better scheduling for CPU cycles
    services.system76-scheduler.settings.cfsProfiles.enable = true;

    # Enable TLP (better than gnomes internal power manager)
    services.tlp = {
      enable = true;
      settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };

    # Disable GNOMEs power management
    services.power-profiles-daemon.enable = false;

    powerManagement.powertop.enable = true;

    # Enable thermald (only necessary if on Intel CPUs)
    services.thermald.enable = cfg.intel;
  };
}
