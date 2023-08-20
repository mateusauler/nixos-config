{ custom, config, lib, pkgs, ... }:

let
  inherit (lib) mkDefault;
  cfg = config.modules.desktop;

  module-names  = [ "browser" "change-wallpaper" "gtk" "hyprland" "nsxiv" "qt" "wally" ];
  other-options = { change-wallpaper.command = "${pkgs.swww}/bin/swww img"; };
in {
  options.modules.desktop.enable = lib.mkEnableOption "desktop";

  config = lib.mkIf cfg.enable {
    modules = let
      join-modules = acc: m: acc // { ${m}.enable = mkDefault true; };
      enabled-modules = (builtins.foldl' join-modules { } module-names);
    in
      lib.attrsets.recursiveUpdate enabled-modules other-options;

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
