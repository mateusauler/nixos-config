{ custom, config, lib, pkgs, ... }:

let
  inherit (lib) mkDefault;
  cfg = config.modules.desktop;

  module-names = [
    "browser"
    "change-wallpaper"
    "ferdium"
    "gtk"
    "hyprland"
    "meld"
    "mpv"
    "neovim.neovide"
    "nsxiv"
    "obs"
    "power-menu"
    "qt"
    "wally"
    "xresources"
  ];
in
{
  options.modules.desktop.enable = lib.mkEnableOption "desktop";

  config = lib.mkIf cfg.enable {
    modules = lib.recursiveUpdate (pkgs.lib.enableModules module-names) {
      change-wallpaper.command = "${pkgs.swww}/bin/swww img";
    };

    programs.direnv = {
      enable = mkDefault true;
      enableBashIntegration = mkDefault true;
      nix-direnv.enable = mkDefault true;
    };

    home.packages = with pkgs; [
      at-spi2-core
      brave
      easyeffects
      firefox
      gimp
      keepassxc
      megasync
      onlyoffice-bin
      pcmanfm
      qbittorrent
      rustdesk
      session-desktop
      signal-desktop
      spotify
      syncthing-tray
      ungoogled-chromium
      vscodium
      vlc
      wl-clipboard
      yt-dlp
      zathura
    ];
  };
}
