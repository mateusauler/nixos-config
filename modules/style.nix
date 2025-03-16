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
    base16Scheme = {
      # Based on https://github.com/tinted-theming/schemes/blob/4ff7fe1cf77217393ed0981a1de314f418c28b49/base16/catppuccin-mocha.yaml
      base00 = "#1e1e2e";
      base01 = "#181825";
      base02 = "#4b5072"; # original: #313244
      base03 = "#6b6f91"; # original: #45475a
      base04 = "#728bc1"; # original: #585b70
      base05 = "#cdd6f4";
      base06 = "#f5e0dc";
      base07 = "#b4befe";
      base08 = "#f38ba8";
      base09 = "#fab387";
      base0A = "#f9e2af";
      base0B = "#a6e3a1";
      base0C = "#94e2d5";
      base0D = "#89b4fa";
      base0E = "#cba6f7";
      base0F = "#f2cdcd";
    };

    image = pkgs.fetchurl {
      url = "https://github.com/mateusauler/wallpapers/blob/b2a40a2d2660700149aaf49ad5bae7f6c5618af1/1deddf6160ff3160.png?raw=true";
      hash = "sha256-BDe4EPXOXGQowbuZGPjAqfHwDQRTLi9kAPDCpfo+DeU=";
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
        name = "FiraCode Nerd Font";
        package = (if pkgs ? nerd-fonts then pkgs.nerd-fonts.fira-code else pkgs.nerdfonts);
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
      noto-fonts-cjk-sans
    ];
  };

  console.font = mkDefault "Lat2-Terminus16";
}
