{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.wget;
  WGETRC = "${config.xdg.configHome}/wget/wgetrc";
in {
  options.modules.wget.enable = lib.mkEnableOption "wget";

  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables = { inherit WGETRC; };
      packages = [ pkgs.wget ];
      activation.create-wgetrc = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p $(dirname "${WGETRC}")
        $DRY_RUN_CMD touch "${WGETRC}"
      '';
    };
  };
}
