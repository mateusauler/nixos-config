{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.nsxiv;
in {
  options.modules.nsxiv.enable = lib.mkEnableOption "nsxiv";

  config = lib.mkIf cfg.enable {
	  home.packages = [ pkgs.nsxiv ];
  };
}
