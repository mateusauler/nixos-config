{ config, lib, ... }:

let
  cfg = config.modules.hyprland;
  workspaces = (lib.attrsets.genAttrs (map toString (lib.range 1 9)) (name: name)) // {
    "0" = "10";
  };
  directionsHJKL = {
    H = "l";
    L = "r";
    K = "u";
    J = "d";
  };
  inherit (cfg) modKey;
in
{
  wayland.windowManager.hyprland.settings = {
    env = [
      # https://wiki.hyprland.org/Configuring/Environment-variables/
      "CLUTTER_BACKEND,wayland" # Clutter package already has wayland enabled, this variable will force Clutter applications to try and use the Wayland backend
      "GDK_BACKEND,wayland,x11" # GTK: Use wayland if available, fall back to x11 if not.
      "QT_AUTO_SCREEN_SCALE_FACTOR,1" # (From the Qt documentation) enables automatic scaling, based on the monitor’s pixel density
      "QT_QPA_PLATFORM,wayland;xcb" # Qt: Use wayland if available, fall back to x11 if not.
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1" # Disables window decorations on Qt applications
      "SDL_VIDEODRIVER,wayland" # Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_DESKTOP,Hyprland"
      "XDG_SESSION_TYPE,wayland"
      "NIXOS_OZONE_WL,1"
    ];

    exec-once = [ "kitty" ];

    input = {
      kb_layout = "br";

      repeat_rate = 50;
      repeat_delay = 400;

      float_switch_override_focus = 0;

      accel_profile = "flat";
    };

    general = with config.colorScheme.palette; {
      border_size = 3;

      "col.active_border" = "rgba(${base0E}ee) rgba(${base0C}ee) 45deg";
      "col.inactive_border" = "rgba(${base01}aa)";

      layout = "dwindle";
    };

    cursor = {
      inactive_timeout = 2;
      persistent_warps = true;
      hide_on_key_press = true;
    };

    "$mon1" = lib.mkDefault "";
    "$mon2" = lib.mkDefault "$mon1";
    "$mon3" = lib.mkDefault "$mon2";

    # monitor = name,resolution,position,scale
    monitor = lib.mkDefault "$mon1,prefered,auto,1";

    decoration = {
      rounding = 5;
      dim_special = "0.4";
      blur = {
        size = 15;
        passes = 4;
      };
    };

    animations = {
      bezier = [
        "easeOutQuint, 0.22, 1, 0.36, 1"
        "easeInOutQuint, 0.83, 0, 0.17, 1"
      ];

      animation = [
        "windows,          1, 3, easeOutQuint"
        "windowsOut,       1, 2, default, popin 50%"
        "border,           1, 5, default"
        "borderangle,      1, 8, default"
        "fade,             1, 2, default"
        "workspaces,       1, 3, easeOutQuint"
        "specialWorkspace, 1, 3, easeOutQuint, slidevert"
        "layers,           1, 3, easeInOutQuint, popin"
      ];
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    master.new_is_master = true;

    misc = {
      vrr = 2;

      animate_manual_resizes = true;
      animate_mouse_windowdragging = true;

      disable_splash_rendering = true;
      disable_hyprland_logo = true;
      background_color = "0x000000";

      initial_workspace_tracking = 2;

      middle_click_paste = !cfg.disable-middle-paste;
    };

    binds = {
      movefocus_cycles_fullscreen = false;
      scroll_event_delay = 80;
    };

    xwayland.force_zero_scaling = true;

    workspace = [ "s[true], gapsout:80, gapsin:20" ];

    windowrulev2 = lib.flatten [
      "workspace 2 silent, class:(librewolf)"
      "workspace 3 silent, class:(KeePassXC)"
      "workspace 4 silent, class:((V|v)encord(D|d)esktop)"
      "workspace 4 silent, class:((V|v)esktop)"
      "workspace 5 silent, class:((F|f)erdium)"
      "workspace 6 silent, class:((S|s)team)"
      "workspace 6 silent, title:((S|s)team)"
      "float,              title:((S|s)team (S|s)ettings)"
      "workspace special silent, class:(Spotify)"

      # Browser screen sharing indicator
      "move 50% 100%-32,         title:^(.*— Sharing Indicator)"
      "minsize 52 32,            title:^(.*— Sharing Indicator)"
      "float,                    title:^(.*— Sharing Indicator)"
      "fakefullscreen,           title:^(.*— Sharing Indicator)"
      "suppressevent fullscreen, title:^(.*— Sharing Indicator)"
      "noinitialfocus,           title:^(.*— Sharing Indicator)"
      "noborder,                 title:^(.*— Sharing Indicator)"

      # CopyQ
      "float,  class:(com\\.github\\.hluk\\.copyq)"
      "center, class:(com\\.github\\.hluk\\.copyq)"
      "pin,    class:(com\\.github\\.hluk\\.copyq)"

      # Mega
      "float, class:(nz\\.co\\.mega\\.)"

      # mpv
      "monitor $mon1, class:(mpv)"
      "fullscreen,    class:(mpv)"

      # Neovide
      "suppressevent maximize, class:(neovide)"

      # nsxiv
      "tile, class:(Nsxiv)"

      # qBitTorrent
      "monitor $mon2,   class:(org\\.qbittorrent\\.qBittorrent)"
      "workspace empty silent, class:(org\\.qbittorrent\\.qBittorrent) title:^(qBittorrent v([0-9]\\.){2}[0-9])$"

      # XWaylandVideoBridge
      "opacity 0.0 override 0.0 override, class:^(xwaylandvideobridge)$"
      "noanim,                            class:^(xwaylandvideobridge)$"
      "nofocus,                           class:^(xwaylandvideobridge)$"
      "noinitialfocus,                    class:^(xwaylandvideobridge)$"

      # Kdeconnect presentation pointer
      "noblur, class:(kdeconnect.daemon)"
      "xray 1, class:(kdeconnect.daemon)"
      "noanim, class:(kdeconnect.daemon)"
      "suppressevent fullscreen, class:(kdeconnect.daemon)"
      "size 100% 100%, class:(kdeconnect.daemon)"
      "noshadow, class:(kdeconnect.daemon)"
      "noborder, class:(kdeconnect.daemon)"
      "center, class:(kdeconnect.daemon)"

      (lib.concatMap
        (game: [
          "monitor $mon1, ${game}"
          "workspace 9,   ${game}"
        ])
        [
          "class:(steam_app.*)" # Steam games
          "class:(factorio)"
          "class:(cs2)"
          "title:(shapez)"
        ]
      )
    ];

    layerrule = [
      "blur,                waybar"
      "ignorezero,          waybar"
      "animation slide top, waybar"

      "dimaround, wofi"

      "animation slide right, notifications"
    ];

    bind = lib.flatten [
      "${modKey},         T, exec, kitty"
      "${modKey},         W, exec, $BROWSER"
      "${modKey} SHIFT,   W, exec, $BROWSER_PRIV"
      "${modKey} CONTROL, W, exec, $BROWSER_PROF"
      "${modKey},         C, exec, copyq show"
      "${modKey},         E, exec, pcmanfm"

      (
        if config.modules.rofi.enable then
          [
            "${modKey},       D,      exec, rofi -show drun -prompt ''"
            "${modKey} SHIFT, D,      exec, rofi -show run  -prompt ''"
            "${modKey},       ESCAPE, exec, rofi -show p -no-show-icons -modi p:rofi-power-menu"
          ]
        else if config.modules.wofi.enable then
          [
            "${modKey},       D, exec, pkill wofi || wofi --show drun --prompt ''"
            "${modKey} SHIFT, D, exec, pkill wofi || wofi --show run  --prompt ''"
          ]
        else
          [ ]
      )

      (lib.optional config.modules.power-menu.enable "${modKey}, ESCAPE, exec, power-menu")

      (lib.optional config.modules.waybar.enable "${modKey}, B, exec, pkill waybar || waybar")

      "${modKey}, PRINT, exec, hyprshot -m window"
      ",          PRINT, exec, hyprshot -m region"

      "${modKey}, X, exec, swaylock"

      "${modKey} SHIFT,   Q, killactive,"
      "${modKey} CONTROL, V, pseudo," # dwindle
      "${modKey},         V, togglesplit," # dwindle
      "${modKey} SHIFT,   V, togglefloating,"

      "${modKey},         F, fullscreen"
      "${modKey} CONTROL, F, fullscreen, 1"
      "${modKey} SHIFT,   F, fakefullscreen"

      "${modKey} SHIFT, N, movecurrentworkspacetomonitor, -1"
      "${modKey},       N, swapactiveworkspaces,          -1 current"

      "${modKey} SHIFT, R,   movetoworkspacesilent, empty"
      "${modKey},       R,   workspace,             empty"
      "${modKey},       TAB, workspace,             previous"

      "${modKey},       COMMA,  focusmonitor,     -1"
      "${modKey} SHIFT, COMMA,  movewindow,   mon:-1"
      "${modKey},       PERIOD, focusmonitor,     +1"
      "${modKey} SHIFT, PERIOD, movewindow,   mon:+1"

      "${modKey} SHIFT, S, movetoworkspacesilent, special"
      "${modKey} SHIFT, S, movetoworkspacesilent, m+0"
      "${modKey},       S, togglespecialworkspace"

      # Scroll through existing workspaces on the same monitor with mainMod + scroll
      "${modKey}, mouse_down, workspace, m+1"
      "${modKey}, mouse_up,   workspace, m-1"

      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

      (lib.mapAttrsToList (key: name:      "${modKey},       ${key}, workspace,             ${name}") workspaces)
      (lib.mapAttrsToList (key: name:      "${modKey} SHIFT, ${key}, movetoworkspacesilent, ${name}") workspaces)
      (lib.mapAttrsToList (key: direction: "${modKey},       ${key}, movefocus,             ${direction}") directionsHJKL)
      (lib.mapAttrsToList (key: direction: "${modKey} SHIFT, ${key}, movewindow,            ${direction}") directionsHJKL)
    ];

    binde = [
      "${modKey}, left,  resizeactive, -50 0"
      "${modKey}, right, resizeactive, 50 0"
      "${modKey}, up,    resizeactive, 0 -50"
      "${modKey}, down,  resizeactive, 0 50"
    ];

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = [
      "${modKey}, mouse:272, movewindow"
      "${modKey}, mouse:273, resizewindow"
    ];

    bindl = [
      ", switch:on:Lid Switch, exec, swaylock"
      ", XF86AudioMute,  exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioPlay,  exec, playerctl play-pause"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioNext,  exec, playerctl next"
      ", XF86AudioPrev,  exec, playerctl previous"
    ];

    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ];

    device =
      map
        (name: {
          sensitivity = -0.93;
          name = "logitech-g903-${name}";
        })
        [
          "lightspeed-wireless-gaming-mouse-w/-hero"
          "lightspeed-wireless-gaming-mouse-w/-hero-1"
          "lightspeed-wireless-gaming-mouse-w/-hero-2"
          "ls-1"
        ];
  };
}
