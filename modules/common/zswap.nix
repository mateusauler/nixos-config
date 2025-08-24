{
  config,
  lib,
  options,
  ...
}:

let
  cfg = config.modules.zswap;
in
{
  options.modules.zswap.enable = lib.mkEnableOption "ZSwap";

  config = lib.mkIf cfg.enable (
    # FIXME: Implemented only on 25.11
    if options.boot.kernel ? sysfs then
      {
        boot.kernel.sysfs.module.zswap.parameters.enabled = true;
      }
    else
      {
        # https://github.com/NixOS/nixpkgs/issues/119244#issuecomment-1250321791
        systemd.services.zswap = {
          description = "Enable ZSwap";
          enable = true;
          wantedBy = [ "basic.target" ];
          script = "echo 1 > /sys/module/zswap/parameters/enabled";
        };
      }
  );
}
