{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = config.modules.niri;

  inherit (lib) mkOption mkEnableOption;

  special = "";

  # Get an output's port. Or, recursively, the previous output's port. Stopping at 1.
  output-port =
    output-number:
    if output-number <= 0 then
      null
    else
      cfg.outputs.${toString output-number}.name or (output-port <| output-number - 1);

  open-on-output =
    n:
    let
      port = output-port n;
    in
    lib.optionalString (port != null) ''open-on-output "${port}"'';

  workspace-open-on-output =
    n:
    let
      rendered-option = open-on-output n;
    in
    lib.optionalString (rendered-option != "") "{ ${rendered-option}; }";

  slowdown = 1;

  special-focus =
    let
      animation-delay = toString (0.275 * slowdown);
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
    '';

  rendered-outputs =
    cfg.outputs
    |> lib.filterAttrs (n: v: v != null)
    |> builtins.mapAttrs (
      n:
      {
        name,
        position,
        focus-at-startup,
        variable-refresh-rate,
      }:
      with position;
      ''
        output "${name}" {
          transform "normal"
          ${lib.optionalString (position != null) "position x=${toString x} y=${toString y}"}
          ${lib.optionalString focus-at-startup "focus-at-startup"}
          ${lib.optionalString variable-refresh-rate "variable-refresh-rate on-demand=false"}
        }
      ''
    )
    |> builtins.attrValues
    |> lib.concatLines;

  rendered-autostart =
    (
      config.modules.desktop.autostart
      |> map (command: [
        "bash"
        "-c"
        command
      ])
    )
    ++ [ ] # Extra auto start
    |> map (lib.toList)
    |> map (map (c: ''"${c}"''))
    |> map (l: [ "spawn-at-startup" ] ++ l)
    |> map (builtins.concatStringsSep " ")
    |> lib.concatLines;
in
{
  options.modules.niri = {
    enable = mkEnableOption "niri" // {
      default = osConfig.modules.niri.enable;
      readOnly = true;
    };

    auto-run-command = mkOption {
      default = "niri-session";
      readOnly = true;
    };

    outputs =
      let
        inherit (lib.types)
          int
          nullOr
          str
          submodule
          ;
      in
      lib.genAttrs [ "1" "2" "3" ] (
        _:
        mkOption {
          default = null;
          type =
            nullOr
            <| submodule {
              options = {
                position = mkOption {
                  default = null;
                  type =
                    nullOr
                    <| submodule {
                      options = {
                        x = mkOption { type = int; };
                        y = mkOption { type = int; };
                      };
                    };
                };

                name = mkOption {
                  default = null;
                  type = nullOr str;
                };

                focus-at-startup = mkOption { default = false; };

                variable-refresh-rate = mkOption { default = false; };
              };
            };
        }
      );
  };

  config = lib.mkIf cfg.enable {
    modules.power-menu.actions.set.logout.command = "systemctl --user stop niri";

    home.packages = with pkgs; [
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

    xdg.configFile."niri/config.kdl".text = ''
      input {
        keyboard {
          xkb {
            layout "br"
          }

          repeat-delay 400
          repeat-rate 50
          track-layout "global"
        }

        touchpad {
          tap
          natural-scroll
        }

        mouse {
          accel-speed -0.93
          accel-profile "flat"
        }

        focus-follows-mouse max-scroll-amount="95%"
        disable-power-key-handling
      }

      screenshot-path "${config.xdg.userDirs.pictures}/screenshots/%Y/%m/%d/%Y-%m-%d_%H-%M-%S.png"

      prefer-no-csd

      hotkey-overlay { skip-at-startup; }

      clipboard { disable-primary; }

      overview { backdrop-color "${config.lib.stylix.colors.withHashtag.base00}"; }

      gestures { hot-corners { off; }; }

      xwayland-satellite { path "${lib.getExe pkgs.xwayland-satellite}"; }

      workspace "1" ${workspace-open-on-output 1}
      workspace "2" ${workspace-open-on-output 2}
      workspace "3" ${workspace-open-on-output 2}
      workspace "4" ${workspace-open-on-output 2}
      workspace "5"
      workspace "6"
      workspace "7"
      workspace "8"
      workspace "9"
      workspace "10"
      workspace "${special}" ${workspace-open-on-output 1}

      ${rendered-outputs}

      ${rendered-autostart}

      layout {
        gaps 16

        struts {
          left 0
          right 0
          top 0
          bottom 0
        }

        focus-ring { off; }

        border {
          width 4
          active-color "${config.lib.stylix.colors.withHashtag.base0D}"
          inactive-color "${config.lib.stylix.colors.withHashtag.base03}"
        }

        tab-indicator {
          gap 5
          width 4
          length total-proportion=0.5
          position "left"
          gaps-between-tabs 5
          corner-radius 5
        }

        default-column-width { proportion 0.5; }

        preset-column-widths {
          proportion 0.25
          proportion 0.333333
          proportion 0.5
          proportion 0.666667
          proportion 0.75
        }

        preset-window-heights {
          proportion 0.25
          proportion 0.333333
          proportion 0.5
          proportion 0.666667
          proportion 0.75
        }

        center-focused-column "never"
      }

      cursor {
        xcursor-theme "${config.stylix.cursor.name}"
        xcursor-size ${toString config.stylix.cursor.size}

        hide-when-typing
        hide-after-inactive-ms 2000
      }

      environment {
        CLUTTER_BACKEND "wayland" // Clutter package already has wayland enabled, this variable will force Clutter applications to try and use the Wayland backend
        GDK_BACKEND "wayland,x11" // GTK: Use wayland if available, fall back to x11 if not.
        SDL_VIDEODRIVER "wayland" // Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
        QT_QPA_PLATFORM "wayland"
        NIXOS_OZONE_WL "1"
      }

      binds {
        Mod+0 { focus-workspace "10"; }
        Mod+1 { focus-workspace "1"; }
        Mod+2 { focus-workspace "2"; }
        Mod+3 { focus-workspace "3"; }
        Mod+4 { focus-workspace "4"; }
        Mod+5 { focus-workspace "5"; }
        Mod+6 { focus-workspace "6"; }
        Mod+7 { focus-workspace "7"; }
        Mod+8 { focus-workspace "8"; }
        Mod+9 { focus-workspace "9"; }
        Mod+S { spawn "${special-focus}"; }

        Mod+Shift+0 { move-column-to-workspace "10"; }
        Mod+Shift+1 { move-column-to-workspace "1"; }
        Mod+Shift+2 { move-column-to-workspace "2"; }
        Mod+Shift+3 { move-column-to-workspace "3"; }
        Mod+Shift+4 { move-column-to-workspace "4"; }
        Mod+Shift+5 { move-column-to-workspace "5"; }
        Mod+Shift+6 { move-column-to-workspace "6"; }
        Mod+Shift+7 { move-column-to-workspace "7"; }
        Mod+Shift+8 { move-column-to-workspace "8"; }
        Mod+Shift+9 { move-column-to-workspace "9"; }
        Mod+Shift+S { move-column-to-workspace "${special}"; }

        Mod+H { focus-column-or-monitor-left; }
        Mod+J { focus-window-or-monitor-down; }
        Mod+K { focus-window-or-monitor-up; }
        Mod+L { focus-column-or-monitor-right; }

        Mod+Ctrl+H { focus-monitor-left; }
        Mod+Ctrl+J { focus-monitor-down; }
        Mod+Ctrl+K { focus-monitor-up; }
        Mod+Ctrl+L { focus-monitor-right; }

        Mod+Shift+H { move-column-left-or-to-monitor-left; }
        Mod+Shift+J { move-window-down; }
        Mod+Shift+K { move-window-up; }
        Mod+Shift+L { move-column-right-or-to-monitor-right; }

        Mod+Shift+Ctrl+H { move-workspace-to-monitor-left; }
        Mod+Shift+Ctrl+J { move-workspace-to-monitor-down; }
        Mod+Shift+Ctrl+K { move-workspace-to-monitor-up; }
        Mod+Shift+Ctrl+L { move-workspace-to-monitor-right; }

        Mod+I       { focus-workspace-up; }
        Mod+Shift+I { move-column-to-workspace-up; }
        Mod+Ctrl+I  { move-workspace-up; }

        Mod+U       { focus-workspace-down; }
        Mod+Shift+U { move-column-to-workspace-down; }
        Mod+Ctrl+U  { move-workspace-down; }

        Mod+Up    { set-window-height "+50"; }
        Mod+Down  { set-window-height "-50"; }
        Mod+Right { set-column-width  "+50"; }
        Mod+Left  { set-column-width  "-50"; }

        Mod+F      { fullscreen-window; }
        Mod+Ctrl+F { maximize-column; }

        Mod+G { toggle-column-tabbed-display; }

        Mod+Comma  { consume-or-expel-window-left; }
        Mod+Period { consume-or-expel-window-right; }

        Mod+R { switch-preset-column-width; }

        Mod+Z      { center-visible-columns; }
        Mod+Ctrl+Z { expand-column-to-available-width; }

        Mod+Tab      { focus-window-previous; }
        Mod+Ctrl+Tab { focus-workspace-previous; }

        Mod+V       { center-column; }
        Mod+Ctrl+V  { switch-focus-between-floating-and-tiling; }
        Mod+Shift+V { toggle-window-floating; }

        Mod+O { toggle-overview; }

        Print     { screenshot show-pointer=false; }
        Mod+Print { screenshot-window write-to-disk=true; }

        Mod+Shift+Q allow-inhibiting=false { close-window; }

        Mod+D       { spawn-sh "pkill wofi || wofi --show drun --prompt '''"; }
        Mod+Shift+D { spawn-sh "pkill wofi || wofi --show run --prompt '''"; }

        ${lib.optionalString config.modules.power-menu.enable ''Mod+Escape { spawn "power-menu"; }''}

        Mod+W         { spawn-sh "$BROWSER"; }
        Mod+Shift+W   { spawn-sh "$BROWSER_PRIV"; }
        Mod+Control+W { spawn-sh "$BROWSER_PROF"; }

        ${lib.optionalString config.modules.waybar.enable ''
          Mod+B       { spawn-sh "pkill -SIGUSR1 waybar || waybar"; }
          Mod+Shift+B { spawn-sh "pkill -SIGUSR2 waybar || waybar"; }
          Mod+Ctrl+B  { spawn-sh "pkill -SIGINT  waybar || waybar"; }
        ''}

        Mod+T { spawn "kitty"; }

        Mod+C { spawn "copyq" "show"; }

        Mod+E { spawn "dolphin"; }

        XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "1%-"; }
        XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "1%+"; }

        XF86AudioMicMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
        XF86AudioMute    { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

        XF86AudioPause { spawn "playerctl" "play-pause"; }
        XF86AudioPlay  { spawn "playerctl" "play-pause"; }
        XF86AudioNext  { spawn "playerctl" "next"; }
        XF86AudioPrev  { spawn "playerctl" "previous"; }
      }

      window-rule {
        geometry-corner-radius 5 5 5 5
        clip-to-geometry true
      }

      window-rule {
        match app-id="[Vv]esktop"
        match app-id="[Dd]iscord"

        open-on-workspace "2"
        open-maximized true
        open-focused false
      }

      window-rule {
        match app-id="[Ff]erdium"

        open-on-workspace "3"
        open-maximized true
        open-focused false
      }

      window-rule {
        match app-id="[Zz]enity"
        match app-id="[Ss]team"
        match title="[Ss]team"

        open-on-workspace "4"
        open-maximized true
        open-focused false
      }

      window-rule {
        match title="[Ss]team [Ss]ettings"

        open-floating true
      }

      window-rule {
        match app-id="org\\.keepassxc\\.KeePassXC"
        match app-id="spotify"
        match app-id="localsend_app"
        match app-id="io.ente.auth"

        exclude app-id="org\\.keepassxc\\.KeePassXC" title="Access Request"
        exclude title="Unlock Database - KeePassXC"

        default-column-width { proportion 0.25; }
        open-on-workspace "${special}"
        open-focused false
      }

      window-rule {
        match app-id="org\\.keepassxc\\.KeePassXC" title="Access Request"
        match title="Unlock Database - KeePassXC"

        open-floating true
        open-focused true
      }

      window-rule {
        match app-id="mpv"

        ${open-on-output 1}
        open-fullscreen true
      }

      window-rule {
        match app-id="steam_app.*" // Steam games
        match app-id="gamescope"
        match app-id="factorio"
        match app-id="cs2"
        match title="shapez( 2)?"
        match app-id="Lightning.bin.x86_64" // Opus Magnum and maybe others
        match app-id="VampireSurvivors.exe"

        open-on-workspace "10"
        open-focused true
      }
    '';
  };
}
