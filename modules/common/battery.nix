{ config, lib, ... }:

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
        CPU_DRIVER_OPMODE_ON_AC = "passive";
        CPU_DRIVER_OPMODE_ON_BAT = "passive";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";
        RUNTIME_PM_ON_AC = "auto";
        WIFI_PWR_ON_AC = "on";
      };
    };

    # Disable GNOMEs power management
    services.power-profiles-daemon.enable = false;

    powerManagement.powertop.enable = true;

    # Enable thermald (only necessary if on Intel CPUs)
    services.thermald.enable = cfg.intel;
  };
}
