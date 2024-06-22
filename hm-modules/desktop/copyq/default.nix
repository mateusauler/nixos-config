{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.copyq;
in
{
  options.modules.copyq.enable = lib.mkEnableOption "CopyQ";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.copyq ];
      # TODO: Link configs with home-manager if not cloning (maybe always link configs?)
      activation.link-copyq-configs =
        lib.hm.dag.entryAfter [ "writeBoundary" ] # bash
          ''
            $DRY_RUN_CMD mkdir -p ${config.xdg.configHome}/copyq
            $DRY_RUN_CMD ${
              if config.dots.clone then "ln -sf ${config.dots.path}/hm-modules/desktop/copyq" else "cp -r ${./.}"
            }/config/* ${config.xdg.configHome}/copyq
          '';

    };
  };
}
