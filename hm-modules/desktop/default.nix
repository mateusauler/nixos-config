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
    ./kitty.nix
    ./librewolf
    ./mako.nix
    ./mega.nix
    ./meld.nix
    ./mpv.nix
    ./nsxiv.nix
    ./obs.nix
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
      hyprland.autostart.apply-wallpaper.command = "swww-daemon";
    };

    qt.enable = true;

    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # Ublock Origin
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
        { id = "oboonakemofpalcgghocfoadofidjkkk"; } # KeePassXC-Browser
        {
          # Chromium Web Store
          id = "ocaahdebbfolfmndjeplogmgcagdmblk";
          updateUrl = "https://raw.githubusercontent.com/NeverDecaf/chromium-web-store/master/updates.xml";
        }
      ];
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
      rustdesk-flutter
      session-desktop
      signal-desktop
      spotify
      swww
      syncthing-tray
      vesktop
      vlc
      vscodium-fhs
      wl-clipboard
      yt-dlp
    ];
  };
}
