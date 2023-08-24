{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.meld;
in {
  options.modules.meld.enable = lib.mkEnableOption "meld";

  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables = { DIFFPROG = "meld"; };
      packages = [ pkgs.meld ];
    };
  };
}

