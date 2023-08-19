{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.desktop;
  inherit (lib) mkDefault;
in {
  options.modules.desktop.enable = lib.mkEnableOption "desktop";

  config = lib.mkIf cfg.enable {
    modules = {
      browser.enable = mkDefault true;
      change-wallpaper = {
        enable = mkDefault true;
        command = "${pkgs.swww}/bin/swww img";
      };
      gtk.enable = mkDefault true;
      hyprland.enable = mkDefault true;
      qt.enable = mkDefault true;
      wally.enable = mkDefault true;
    };

    home.packages = with pkgs; [
      at-spi2-core
      brave
      easyeffects
      ferdium
      firefox
      keepassxc
      megasync
      mpv
      neovide
      nsxiv
      onlyoffice-bin
      pcmanfm
      qbittorrent
      spotify
      syncthing-tray
      ungoogled-chromium
      vscodium
      yt-dlp
      zathura
    ];
  };
}
