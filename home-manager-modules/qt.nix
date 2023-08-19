{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.qt;
in {
  options.modules.qt.enable = lib.mkEnableOption "qt";

  config = lib.mkIf cfg.enable {
    qt.enable = true;
    qt.platformTheme = "gtk";
    qt.style.name = "Arc-dark";
    qt.style.package = pkgs.arc-theme;
  };
}
