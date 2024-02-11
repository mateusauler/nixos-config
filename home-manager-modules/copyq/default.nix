{ config, lib, pkgs, ... }:

let
  cfg = config.modules.copyq;
in
{
  options.modules.copyq.enable = lib.mkEnableOption "CopyQ";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.copyq ];
      # TODO: Link configs with home-manager if not cloning (maybe always link configs?)
      activation.link-copyq-configs = lib.optionalString config.dots.clone lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p ${config.xdg.configHome}/copyq
        $DRY_RUN_CMD ln -sf ${config.dots.path}/home-manager-modules/copyq/config/* ${config.xdg.configHome}/copyq
      '';
    };
  };
}
