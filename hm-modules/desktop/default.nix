{ config, lib, pkgs, pkgs-unstable, ... }:

let
  inherit (lib) mkDefault;
  cfg = config.modules.desktop;

  module-names = [
    "browser"
    "change-wallpaper"
    "direnv"
    "ferdium"
    "gtk"
    "hyprland"
    "mega"
    "meld"
    "mpv"
    "neovim.neovide"
    "nsxiv"
    "obs"
    "power-menu"
    "qt"
    "xresources"
    "zathura"
  ];
in
{
  options.modules.desktop.enable = lib.mkEnableOption "desktop";

  imports = [
    ./copyq
    ./ferdium.nix
    ./gtk.nix
    ./hyprland
    ./kitty
    ./librewolf
    ./mako.nix
    ./mega.nix
    ./meld.nix
    ./mpv.nix
    ./nsxiv.nix
    ./obs.nix
    ./qt.nix
    ./rofi
    ./scripts
    ./smm.nix
    ./swaylock.nix
    ./waybar
    ./wofi.nix
    ./xresources.nix
    ./zathura.nix
  ];

  config = lib.mkIf cfg.enable {
    modules = lib.recursiveUpdate (pkgs.lib.enableModules module-names) {
      change-wallpaper.command = "swww img";
      hyprland.autostart.apply-wallpaper.command = "sleep 0.5 && swww init";
    };

    home.packages = with pkgs; [
      at-spi2-core
      brave
      easyeffects
      firefox
      gimp
      keepassxc
      onlyoffice-bin
      pcmanfm
      qbittorrent
      pkgs-unstable.rustdesk-flutter
      session-desktop
      signal-desktop
      spotify
      swww
      syncthing-tray
      ungoogled-chromium
      vesktop
      vlc
      vscodium-fhs
      wl-clipboard
      yt-dlp
    ];
  };
}
