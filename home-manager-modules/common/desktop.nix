{ custom, config, lib, pkgs, ... }:

let
  inherit (lib) mkDefault;
  cfg = config.modules.desktop;

  module-names  = [ "browser" "change-wallpaper" "gtk" "hyprland" "meld" "nsxiv" "obs" "qt" "wally" ];
  other-options = { change-wallpaper.command = "${pkgs.swww}/bin/swww img"; };
in {
  options.modules.desktop.enable = lib.mkEnableOption "desktop";

  config = lib.mkIf cfg.enable {
    modules = pkgs.lib.enableModules { inherit module-names other-options; };

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
      onlyoffice-bin
      pcmanfm
      qbittorrent
      session-desktop
      spotify
      syncthing-tray
      ungoogled-chromium
      vscodium
      wl-clipboard
      yt-dlp
      zathura
    ];
  };
}
