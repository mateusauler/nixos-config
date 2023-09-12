{ config, lib, nix-colors, pkgs, ... }:

let
  cfg = config.modules.qt;
  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
in {
  options.modules.qt.enable = lib.mkEnableOption "qt";

  config = lib.mkIf cfg.enable {
    qt = {
      enable = true;
      platformTheme = "gtk";
      style = {
        package = nix-colors-lib.gtkThemeFromScheme {
          scheme = config.colorScheme;
        };
        name = "${config.colorScheme.slug}";
      };
    # qt.style.name = "Arc-dark";
    # qt.style.package = pkgs.arc-theme;
    };
  };
}
