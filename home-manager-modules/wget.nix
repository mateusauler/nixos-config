{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.wget;
in {
  options.modules.wget.enable = lib.mkEnableOption "wget";

  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables = { WGETRC = "${config.xdg.configHome}/wget/wgetrc"; };
      packages = [ pkgs.wget ];
      activation.create-wgetrc = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -z "$WGETRC" ]; then
          $DRY_RUN_CMD mkdir -p $($DRY_RUN_CMD dirname "$WGETRC")
          $DRY_RUN_CMD touch "$WGETRC"
        fi
      '';
    };
  };
}
