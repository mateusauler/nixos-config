{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.qt;
in
{
  options.modules.qt.enable = lib.mkEnableOption "qt";

  config = lib.mkIf cfg.enable {
    qt = {
      enable = true;
      platformTheme.name = "gtk";
      style = {
        package = config.gtk.theme.package;
        name = "gtk2";
      };
    };

    home.packages = with pkgs; [
      libsForQt5.qtstyleplugins
      kdePackages.qt6gtk2
    ];
  };
}
