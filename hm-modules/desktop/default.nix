{
  config,
  lib,
  osConfig,
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
  options.modules.desktop = {
    enable = lib.mkEnableOption "desktop" // {
      default = osConfig.modules.desktop.enable;
      readOnly = true;
    };
    autostart = lib.mkOption {
      type =
        with lib.types;
        either (listOf str) str
        // {
          merge = loc: defs: defs |> map (v: v.value) |> lib.flatten;
        };
    };
  };

  imports = [
    ./chromium.nix
    ./copyq
    ./dolphin.nix
    ./ferdium.nix
    ./gtk.nix
    ./kitty.nix
    ./librewolf
    ./mega.nix
    ./meld.nix
    ./mpv.nix
    ./nixcord.nix
    ./obs.nix
    ./rofi
    ./scripts
    ./smm.nix
    ./vscodium.nix
    ./wayland
    ./xresources.nix
    ./zathura.nix
  ];

  config = lib.mkIf cfg.enable {
    modules = lib.recursiveUpdate (pkgs.lib.enableModules module-names) {
      change-wallpaper = {
        command = "swww img";
        daemon = "swww-daemon";
      };
    };

    qt.enable = true;

    home.packages = with pkgs; [
      anytype
      at-spi2-core
      brave
      bruno
      devenv
      ente-auth
      firefox
      gimp3
      keepassxc
      libreoffice-fresh
      nsxiv
      onlyoffice-bin
      qbittorrent
      rustdesk-flutter
      session-desktop
      signal-desktop
      sops
      spotify
      swww
      vlc
      yt-dlp
    ];
  };
}
