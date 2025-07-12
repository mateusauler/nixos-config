{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = config.modules.niri;
  module-names = [ ];
in
{
  options.modules.niri = {
    enable = lib.mkEnableOption "niri" // {
      default = osConfig.programs.niri.enable;
      readOnly = true;
    };
    auto-run-command = lib.mkOption {
      default = "bash -c niri-session";
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    modules = lib.recursiveUpdate (pkgs.lib.enableModules module-names) {
      power-menu.actions.set.logout.command = "systemctl --user stop niri";
    };

    home.packages = [ pkgs.xwayland-satellite-unstable ];

    services.gnome-keyring.enable = lib.mkForce false;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
    };

    programs.niri = {
      settings = {
        environment = {
          # https://wiki.hyprland.org/Configuring/Environment-variables/
          CLUTTER_BACKEND = "wayland"; # Clutter package already has wayland enabled, this variable will force Clutter applications to try and use the Wayland backend
          GDK_BACKEND = "wayland,x11"; # GTK: Use wayland if available, fall back to x11 if not.
          SDL_VIDEODRIVER = "wayland"; # Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
          QT_QPA_PLATFORM = "wayland";
          NIXOS_OZONE_WL = "1";
        };

        spawn-at-startup = lib.flatten [
          (map (c: {
            command = [
              "bash"
              "-c"
              c
            ];
          }) config.modules.desktop.autostart)
          { command = [ "kitty" ]; }
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite-unstable;

        screenshot-path = "${config.xdg.userDirs.pictures}/screenshots/%Y/%m/%d/%Y-%m-%d_%H-%M-%S.png";

        hotkey-overlay.skip-at-startup = true;
        clipboard.disable-primary = true;
        prefer-no-csd = true;

        workspaces = {

        };

        input = {
          focus-follows-mouse.enable = true;

          keyboard = {
            repeat-delay = 400;
            repeat-rate = 50;
            xkb.layout = "br";
          };

          mouse = {
            accel-profile = "flat";
            accel-speed = -0.93;
          };

          power-key-handling.enable = false;

          warp-mouse-to-focus = {
            enable = true;
            mode = "center-xy";
          };
        };

        cursor = {
          hide-after-inactive-ms = 2000;
          hide-when-typing = true;
        };

        binds =
          with config.lib.niri.actions;
          let
            sh = spawn "bash" "-c";
          in
          {
            "Mod+T".action.spawn = "kitty";
            "Mod+W".action = sh "$BROWSER";
            "Mod+Shift+W".action = sh "$BROWSER_PRIV";
            "Mod+Control+W".action = sh "$BROWSER_PROF";
            "Mod+C".action = spawn "copyq" "show";
            "Mod+E".action.spawn = config.modules.wayland.file-manager;

            "Mod+Escape".action = lib.mkIf config.modules.power-menu.enable (spawn "power-menu");

            "Mod+D".action = sh "pkill wofi || wofi --show drun --prompt ''";
            "Mod+Shift+D".action = sh "pkill wofi || wofi --show run --prompt ''";

            "Mod+B".action = lib.mkIf config.modules.waybar.enable (sh "pkill waybar || waybar");

            "Print".action.screenshot.show-pointer = false;
            "Mod+Print".action.screenshot-window.write-to-disk = true;

            "Mod+Shift+Q".action = close-window;

            "Mod+O".action = toggle-overview;
            "Mod+G".action = toggle-column-tabbed-display;

            "Mod+H".action = focus-column-or-monitor-left;
            "Mod+J".action = focus-window-or-monitor-down;
            "Mod+K".action = focus-window-or-monitor-up;
            "Mod+L".action = focus-column-or-monitor-right;

            "Mod+Shift+H".action = move-column-left-or-to-monitor-left;
            "Mod+Shift+J".action = move-window-down;
            "Mod+Shift+K".action = move-window-up;
            "Mod+Shift+L".action = move-column-right-or-to-monitor-right;

            "Mod+U".action = focus-workspace-down;
            "Mod+I".action = focus-workspace-up;

            "Mod+Shift+U".action = move-column-to-workspace-down;
            "Mod+Shift+I".action = move-column-to-workspace-up;

            "Mod+Ctrl+U".action = move-workspace-down;
            "Mod+Ctrl+I".action = move-workspace-up;

            "Mod+Comma".action = consume-or-expel-window-left;
            "Mod+Period".action = consume-or-expel-window-right;

            "Mod+R".action = switch-preset-column-width;
            "Mod+F".action = fullscreen-window;
            "Mod+Ctrl+F".action = maximize-column;
            "Mod+Ctrl+Z".action = expand-column-to-available-width;

            "Mod+V".action = center-column;
            "Mod+Shift+V".action = toggle-window-floating;
            "Mod+Ctrl+V".action = switch-focus-between-floating-and-tiling;
            "Mod+Z".action = center-visible-columns;

            "Mod+Right".action = set-column-width "+50";
            "Mod+Left".action = set-column-width "-50";

            "Mod+Up".action = set-window-height "+50";
            "Mod+Down".action = set-window-height "-50";

            "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "1%+";
            "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "1%-";

            "XF86AudioMicMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";

            "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
            "XF86AudioPlay".action = spawn "playerctl" "play-pause";
            "XF86AudioPause".action = spawn "playerctl" "play-pause";
            "XF86AudioNext".action = spawn "playerctl" "next";
            "XF86AudioPrev".action = spawn "playerctl" "previous";
          };

        layout = {
          preset-column-widths = [
            { proportion = 1.0 / 2.0; }
            { proportion = 1.0 / 3.0; }
            { proportion = 2.0 / 3.0; }
          ];

          preset-window-heights = [
            { proportion = 1.0 / 2.0; }
            { proportion = 1.0 / 3.0; }
            { proportion = 2.0 / 3.0; }
          ];
        };
      };
    };
  };
}
