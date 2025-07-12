{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  module-names = [
    "copyq"
    "kitty"
    "mako"
    "swaylock"
    "waybar"
    "wofi"
  ];
  cfg = config.modules.wayland;
in
{
  options.modules.wayland = {
    enable = lib.mkEnableOption "Wayland" // {
      default = config.modules.hyprland.enable || config.modules.niri.enable;
    };
    disable-middle-paste = lib.mkOption { default = true; };
    file-manager = lib.mkOption { type = lib.types.str; };
  };

  imports = [
    ./hyprland
    ./mako.nix
    ./swaylock.nix
    ./waybar
    ./wofi.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      lib.flatten [
        libnotify
        playerctl
        wlsunset
        wl-clipboard
        # Temporary fix for https://github.com/hyprwm/Hyprland/issues/6725
        # (lib.optional config.modules.copyq.enable wl-clip-persist)
        (lib.optional config.modules.rofi.enable rofi-power-menu)
      ];

    modules = lib.recursiveUpdate (pkgs.lib.enableModules module-names) {
      desktop.autostart = lib.flatten [
        # "wl-clip-persist --clipboard regular"
        "wlsunset -s 18:00 -S 7:00 -t 4500"
        (lib.optional osConfig.programs.kdeconnect.enable "kdeconnect-indicator")
      ];
    };
  };
}
