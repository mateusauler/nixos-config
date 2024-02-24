{ config, lib, pkgs, ... }:

let
  cfg = config.modules.zswap;
in
{
  options.modules.zswap.enable = lib.mkEnableOption "ZSwap";

  config = lib.mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/issues/119244#issuecomment-1250321791
    systemd.services.zswap = {
      description = "Enable ZSwap, set to ZSTD and Z3FOLD";
      enable = true;
      wantedBy = [ "basic.target" ];
      serviceConfig = {
        ExecStart = /* bash */ ''
          ${lib.getExe pkgs.bash} -c 'cd /sys/module/zswap/parameters && \
          echo 1 > enabled && \
          echo 20 > max_pool_percent && \
          echo zstd > compressor && \
          echo z3fold > zpool'
        '';
        Type = "simple";
      };
    };
  };
}
