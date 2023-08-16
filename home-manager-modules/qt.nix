{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.qt;
in {
  options.modules.qt.enable = lib.mkEnableOption "qt";


  config = lib.mkIf cfg.enable {
    qt.enable = true;
    qt.platformTheme = "gtk";
    # qt.style.name = "kvantum";
    # qt.style.package = pkgs.libsForQt5.qtstyleplugins;
    # qt.style.package = pkgs.libsForQt5.qtstyleplugin-kvantum;
    # home.packages = [ pkgs.libsForQt5.qtstyleplugins ];
    # home.packages = with pkgs; [ qt5ct qt6ct ];

    home.packages = with pkgs; [
      arc-kde-theme
      # libsForQt5.qtstyleplugin-kvantum
    ];

    # gtk.iconTheme.package = pkgs.papirus-icon-theme;
    # gtk.iconTheme.name = "Papirus-Dark";

    # gtk.theme.package = pkgs.materia-theme;
    # gtk.theme.name = "Materia-dark-compact";

    # theme=KvArcDark
    # xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    #   [General]
    #   theme=KvArcDark
    # '';

    home.sessionVariables = {
      # QT_STYLE_OVERRIDE = "kvantum";
      QT_QPA_PLATFORMTHEME = "gtk2";
      GTK_USE_PORTAL = 1;
    };
  };
}