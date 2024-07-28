{
  config,
  lib,
  pkgs,
  ...
}:

let
inherit (lib) mkDefault;
in
{
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    image = pkgs.fetchurl {
      url = "https://github.com/mateusauler/wallpapers/blob/b2a40a2d2660700149aaf49ad5bae7f6c5618af1/2f0f4a54acb220ce.jpg?raw=true";
      hash = "sha256-GdPWrMOI3huXoMXnXboq90DWFZhNljz4vJe+fmVBHdQ=";
    };

    opacity = {
      desktop = 0.5;
      terminal = 0.8;
    };

    cursor = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir";
      size = 24;
    };

    fonts = {
      sizes = {
        applications = mkDefault 12;
        desktop = mkDefault 10;
        popups = mkDefault 10;
        terminal = mkDefault 12;
      };

      monospace = {
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerdfonts;
      };

      sansSerif = {
        name = "Roboto";
        package = pkgs.roboto;
      };

      serif = config.stylix.fonts.sansSerif;

      emoji = {
        name = "Blobmoji";
        package = pkgs.noto-fonts-emoji-blob-bin;
      };
    };
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      font-awesome
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
    ];
  };

  console.font = mkDefault "Lat2-Terminus16";
}
