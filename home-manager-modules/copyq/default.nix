{ config, custom, lib, pkgs, ... }:

let
  inherit (custom) dots-path;
  cfg = config.modules.copyq;
in
{
  options.modules.copyq.enable = lib.mkEnableOption "CopyQ";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.copyq ];
      activation.link-copyq-configs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p ${config.xdg.configHome}/copyq
        $DRY_RUN_CMD ln -sf ${dots-path}/home-manager-modules/copyq/config/* ${config.xdg.configHome}/copyq
      '';
    };
  };
}
