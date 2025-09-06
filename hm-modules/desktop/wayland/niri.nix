{
  config,
  lib,
  options,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = config.modules.niri;

  inherit (lib) mkOption mkEnableOption;

  # keyboard key => identifier
  workspaces-by-key = (lib.range 1 9 |> map toString |> (l: lib.genAttrs l (n: n))) // {
    "0" = "10";
  };

  special = "";

  # Get an output's port. Or, recursively, the previous output's port. Stopping at 1.
  output-port =
    output-number:
    if output-number <= 0 then
      null
    else
      cfg.outputs.${toString output-number}.name or (output-port <| output-number - 1);
in
{
  options.modules.niri = {
    enable = mkEnableOption "niri" // {
      default = osConfig.programs.niri.enable;
      readOnly = true;
    };
    auto-run-command = mkOption {
      default = "bash -c niri-session";
      readOnly = true;
    };
    outputs =
      let
        inherit (lib.types) submodule nullOr;

        # Get a nested element type's subOptions
        subOptions = opt: opt.type.nestedTypes.elemType.getSubOptions [ ];

        type =
          nullOr
          <| submodule {
            # Reuse niri's original output module's options
            options =
              options.programs.niri.settings
              |> subOptions
              |> (s: s.outputs)
              |> subOptions
              |> lib.filterAttrs (n: v: n != "_module") # Unneeded metadata
            ;
          };
      in
      lib.genAttrs [ "1" "2" "3" ] (
        _:
        mkOption {
          inherit type;
          default = null;
        }
      );
  };

  config = lib.mkIf cfg.enable {
    modules.power-menu.actions.set.logout.command = "systemctl --user stop niri";

    home.packages = with pkgs; [
      # https://github.com/sodiboo/niri-flake/issues/437
      nautilus
      xwayland-satellite
    ];

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
          (
            config.modules.desktop.autostart
            |> map (command: {
              command = [
                "bash"
                "-c"
                command
              ];
            })
          )

          { command = [ "kitty" ]; }
          { command = [ "keepassxc" ]; }
          { command = [ "spotify" ]; }
          { command = [ "enteauth" ]; }
          { command = [ "localsend_app" ]; }
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite-unstable;

        screenshot-path = "${config.xdg.userDirs.pictures}/screenshots/%Y/%m/%d/%Y-%m-%d_%H-%M-%S.png";

        hotkey-overlay.skip-at-startup = true;
        clipboard.disable-primary = config.modules.wayland.disable-middle-paste;
        prefer-no-csd = true;

        # Remove custom port option
        outputs = lib.filterAttrs (_: v: v != null) cfg.outputs;

        # Workspaces are numbered 0 to 9 and named 1 to 10.
        # There is also the special workspace.
        workspaces =
          lib.range 0 9
          |>
            builtins.foldl'
              (
                acc: name:
                lib.recursiveUpdate acc {
                  ${toString name}.name = toString (name + 1);
                }
              )
              # Extra workspace settings
              {
                ${special}.open-on-output = output-port 1;
                "0".open-on-output = output-port 1;
                "1".open-on-output = output-port 2;
                "2".open-on-output = output-port 3;
                "3".open-on-output = output-port 3;
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

        layout = {
          preset-column-widths = [
            { proportion = 1. / 2.; }
            { proportion = 1. / 4.; }
            { proportion = 1. / 3.; }
            { proportion = 2. / 3.; }
            { proportion = 3. / 4.; }
          ];

          preset-window-heights = [
            { proportion = 1. / 2.; }
            { proportion = 1. / 4.; }
            { proportion = 1. / 3.; }
            { proportion = 2. / 3.; }
            { proportion = 3. / 4.; }
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
              ] (_: 5.0)
            );
            clip-to-geometry = true;
          }

          # Window Specific
          {
            matches = [
              { app-id = "[Vv]esktop"; }
              { app-id = "[Dd]iscord"; }
            ];
            open-on-workspace = "2";
            open-focused = false;
            open-maximized = true;
          }
          {
            matches = [ { app-id = "[Ff]erdium"; } ];
            open-on-workspace = "3";
            open-focused = false;
            open-maximized = true;
          }
          {
            matches = [
              { app-id = "[Zz]enity"; }
              { app-id = "[Ss]team"; }
              { title = "[Ss]team"; }
            ];
            open-on-workspace = "4";
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
              { app-id = "io.ente.auth"; }
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
            default-column-width.proportion = 1.0 / 4.0;
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
            open-on-output = output-port 1;
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

        overview.backdrop-color = config.lib.stylix.colors.base00;

        gestures.hot-corners.enable = false;

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

            "Mod+D".action = sh "pkill wofi || wofi --show drun --prompt ''";
            "Mod+Shift+D".action = sh "pkill wofi || wofi --show run --prompt ''";

            "Print".action.screenshot.show-pointer = false;
            "Mod+Print".action.screenshot-window.write-to-disk = true;

            "Mod+Shift+Q" = {
              action = close-window;
              allow-inhibiting = false;
            };

            "Mod+Tab".action = focus-workspace-previous;
            "Mod+Ctrl+Tab".action = focus-window-previous;

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

            "Mod+S".action.spawn = toString (
              let
                slowdown = config.programs.niri.settings.animations.slowdown;
                animation-delay = toString (0.275 * (if slowdown != null then slowdown else 1));
              in
              pkgs.writeShellScript "special-focus" ''
                # The currently focused workspace
                current_workspace=$(niri msg -j workspaces | jq -r '.[] | select(.is_focused).name')
                if [[ $current_workspace == ${special} ]]
                then
                  niri msg action focus-workspace-previous
                  # Let the animation finish
                  sleep ${animation-delay}
                  # The special workspace should be the last one
                  niri msg action move-workspace-to-index --reference ${special} $(niri msg -j workspaces | jq '. | length')
                else
                  # The currently focused output
                  output=$(niri msg -j focused-output | jq -r .name)
                  # The output that the special workspace is currently in
                  special_output=$(niri msg -j workspaces | jq -r '.[] | select(.name == "${special}").output')

                  if [[ $output != $special_output ]]
                  then
                    # Is the special workspace active in its current output?
                    if $(niri msg -j workspaces | jq -r '.[] | select(.name == "${special}").is_active')
                    then
                      # Focus the previous workspace in the special workspace's output
                      niri msg action focus-workspace ${special}
                      niri msg action focus-workspace-previous
                      # Let the animation finish
                      sleep ${animation-delay}
                    fi

                    # Move the special workspace to the new output
                    niri msg action move-workspace-to-monitor --reference ${special} $output
                  fi

                  # Move the special workspace to the next position so that the animation isn't so horrible
                  current_workspace_index=$(niri msg -j workspaces | jq -r '.[] | select(.is_focused).idx')
                  niri msg action move-workspace-to-index --reference ${special} $((current_workspace_index + 1))

                  niri msg action focus-workspace ${special}
                fi
              ''
            );
            "Mod+Shift+S".action.move-column-to-workspace = special;
          }
          // (
            workspaces-by-key
            |> lib.mapAttrs' (n: v: lib.nameValuePair "Mod+${n}" { action.focus-workspace = v; })
          )
          // (
            workspaces-by-key
            |> lib.mapAttrs' (n: v: lib.nameValuePair "Mod+Shift+${n}" { action.move-column-to-workspace = v; })
          )
          // (
            { "Mod+Escape".action = spawn "power-menu"; } |> lib.optionalAttrs config.modules.power-menu.enable
          )
          // (
            {
              "Mod+B".action = sh "pkill -SIGUSR1 waybar || waybar"; # Toggle
              "Mod+Shift+B".action = sh "pkill -SIGUSR2 waybar || waybar"; # Reload
              "Mod+Ctrl+B".action = sh "pkill -SIGINT waybar || waybar"; # Quit
            }
            |> lib.optionalAttrs config.modules.waybar.enable
          );
      };
    };
  };
}
