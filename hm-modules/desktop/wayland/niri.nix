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
  workspaces-by-number = (lib.genAttrs (map toString (lib.range 1 9)) (name: name)) // {
    "0" = "10";
  };
  special = "";
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
          { command = [ "keepassxc" ]; }
          { command = [ "localsend_app" ]; }
          { command = [ "spotify" ]; }
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite-unstable;

        screenshot-path = "${config.xdg.userDirs.pictures}/screenshots/%Y/%m/%d/%Y-%m-%d_%H-%M-%S.png";

        hotkey-overlay.skip-at-startup = true;
        clipboard.disable-primary = config.modules.wayland.disable-middle-paste;
        prefer-no-csd = true;

        workspaces =
          lib.range 0 9
          |>
            builtins.foldl'
              (
                acc: name:
                acc
                // {
                  ${toString name}.name = toString (name + 1);
                }
              )
              {
                ${special} = { };
              };

        input = {
          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "95%";
          };

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

            "Mod+Tab".action = focus-workspace-previous;

            "Mod+O".action = toggle-overview;
            "Mod+G".action = toggle-column-tabbed-display;

            "Mod+H".action = focus-column-or-monitor-left;
            "Mod+J".action = focus-window-or-monitor-down;
            "Mod+K".action = focus-window-or-monitor-up;
            "Mod+L".action = focus-column-or-monitor-right;

            "Mod+Ctrl+H".action = focus-monitor-left;
            "Mod+Ctrl+J".action = focus-monitor-down;
            "Mod+Ctrl+K".action = focus-monitor-up;
            "Mod+Ctrl+L".action = focus-monitor-right;

            "Mod+Shift+H".action = move-column-left-or-to-monitor-left;
            "Mod+Shift+J".action = move-window-down;
            "Mod+Shift+K".action = move-window-up;
            "Mod+Shift+L".action = move-column-right-or-to-monitor-right;

            "Mod+Shift+Ctrl+H".action = move-workspace-to-monitor-left;
            "Mod+Shift+Ctrl+J".action = move-workspace-to-monitor-down;
            "Mod+Shift+Ctrl+K".action = move-workspace-to-monitor-up;
            "Mod+Shift+Ctrl+L".action = move-workspace-to-monitor-right;

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

            "Mod+S".action.focus-workspace = special;
            "Mod+Shift+S".action.move-column-to-workspace = special;
          }
          // (
            workspaces-by-number
            |> lib.mapAttrs' (n: v: lib.nameValuePair "Mod+${n}" { action.focus-workspace = v; })
          )
          // (
            workspaces-by-number
            |> lib.mapAttrs' (n: v: lib.nameValuePair "Mod+Shift+${n}" { action.move-column-to-workspace = v; })
          );

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

          default-column-width.proportion = 1.0 / 2.0;

          tab-indicator = {
            gaps-between-tabs = 5;
            corner-radius = 5;
          };
        };

        window-rules = [
          # General
          {
            geometry-corner-radius = (
              lib.genAttrs [
                "bottom-left"
                "bottom-right"
                "top-left"
                "top-right"
              ] (a: 5.0)
            );
            clip-to-geometry = true;
          }

          # Window Specific
          {
            matches = [ { app-id = "librewolf"; } ];
            open-on-workspace = "2";
            open-focused = false;
            open-maximized = true;
          }
          {
            matches = [
              { app-id = "[Vv]esktop"; }
              { app-id = "[Dd]iscord"; }
            ];
            open-on-workspace = "3";
            open-focused = false;
            open-maximized = true;
          }
          {
            matches = [ { app-id = "[Ff]erdium"; } ];
            open-on-workspace = "4";
            open-focused = false;
            open-maximized = true;
          }
          {
            matches = [
              { app-id = "[Zz]enity"; }
              { app-id = "[Ss]team"; }
              { title = "[Ss]team"; }
            ];
            open-on-workspace = "5";
            open-focused = false;
            open-maximized = true;
          }
          {
            matches = [ { title = "[Ss]team [Ss]ettings"; } ];
            open-floating = true;
          }
          {
            matches = [
              { app-id = "org\\.keepassxc\\.KeePassXC"; }
              { app-id = "spotify"; }
              { app-id = "localsend_app"; }
            ];
            excludes = [
              {
                app-id = "org\\.keepassxc\\.KeePassXC";
                title = "Access Request";
              }
              { title = "Unlock Database - KeePassXC"; }
            ];
            open-on-workspace = special;
            open-focused = false;
            default-column-width.proportion = 1.0 / 3.0;
          }
          {
            matches = [
              {
                app-id = "org\\.keepassxc\\.KeePassXC";
                title = "Access Request";
              }
              { title = "Unlock Database - KeePassXC"; }
            ];
            open-floating = true;
            open-focused = true;
          }
          {
            matches = [ { app-id = "mpv"; } ];
            open-fullscreen = true;
          }

          # Games
          {
            matches = [
              { app-id = "steam_app.*"; } # Steam games
              { app-id = "gamescope"; }
              { app-id = "factorio"; }
              { app-id = "cs2"; }
              { title = "shapez( 2)?"; }
              { app-id = "Lightning.bin.x86_64"; } # Opus Magnum and maybe others
              { app-id = "VampireSurvivors.exe"; }
            ];
            open-on-workspace = "10";
            open-focused = true;
          }
        ];

        gestures.hot-corners.enable = false;
      };
    };
  };
}
