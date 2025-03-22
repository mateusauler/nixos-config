{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.desktop;

  module-names = [
    "browser"
    "change-wallpaper"
    "chromium"
    "direnv"
    "dolphin"
    "ferdium"
    "gtk"
    "hyprland"
    "mega"
    "meld"
    "mpv"
    "neovim.neovide"
    "nixcord"
    "obs"
    "power-menu"
    "vscodium"
    "xresources"
    "zathura"
  ];
in
{
  options.modules.desktop.enable = lib.mkEnableOption "desktop";

  imports = [
    ./chromium.nix
    ./copyq
    ./dolphin.nix
    ./ferdium.nix
    ./gtk.nix
    ./hyprland
    ./kitty.nix
    ./librewolf
    ./mako.nix
    ./mega.nix
    ./meld.nix
    ./mpv.nix
    ./nixcord.nix
    ./obs.nix
    ./rofi
    ./scripts
    ./smm.nix
    ./swaylock.nix
    ./vscodium.nix
    ./waybar
    ./wofi.nix
    ./xresources.nix
    ./zathura.nix
  ];

  config = lib.mkIf cfg.enable {
    modules = lib.recursiveUpdate (pkgs.lib.enableModules module-names) {
      change-wallpaper.command = "swww img";
      hyprland.autostart.apply-wallpaper.command = "swww-daemon";
    };

    qt.enable = true;

    home.packages = with pkgs; [
      anytype
      at-spi2-core
      brave
      firefox
      gimp
      keepassxc
      nsxiv
      onlyoffice-bin
      qbittorrent
      rustdesk-flutter
      session-desktop
      signal-desktop
      spotify
      swww
      vlc
      wl-clipboard
      yt-dlp
    ];
  };
}
