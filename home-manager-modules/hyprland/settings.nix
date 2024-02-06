{ config, custom, lib, ... }:

let
  cfg = config.modules.hyprland;
  workspaces = (lib.attrsets.genAttrs (map toString (lib.range 1 9)) (name: name)) // { "0" = "10"; };
  directionsArrows = { left = "l"; right = "r"; up = "u"; down = "d"; };
  directionsHJKL   = { H    = "l"; L     = "r"; K  = "u"; J    = "d"; };
  # FIXME: Improve readability
  # TODO: Extract this & allow user to configure via module
  # TODO: Use nix-colors
  swaylock = "swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 10x8 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2";
  inherit (cfg) modKey;
in
{
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
  ];

  exec-once = [ "kitty" ] ++ lib.optional cfg.disable-middle-paste "wl-paste -p --watch wl-copy -p ''";

  input = {
    kb_layout = custom.keyboard-layout;

    repeat_rate = 50;
    repeat_delay = 400;

    float_switch_override_focus = 0;

    accel_profile = "flat";
  };

  general = with config.colorScheme.colors; {
    border_size = 3;

    "col.active_border"   = "rgba(${base0E}ee) rgba(${base0C}ee) 45deg";
    "col.inactive_border" = "rgba(${base01}aa)";

    layout = "dwindle";
    cursor_inactive_timeout = 2;
  };

  decoration = {
    rounding = 5;
    dim_special = "0.4";
    blur = {
      size = 10;
      passes = 2;
    };
  };

  animations = {
    bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

    animation = [
      "windows,     1, 5,  myBezier"
      "windowsOut,  1, 7,  default, popin 80%"
      "border,      1, 10, default"
      "borderangle, 1, 8,  default"
      "fade,        1, 7,  default"
      "workspaces,  1, 4,  default"
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
  };

  binds.scroll_event_delay = 80;

  windowrulev2 = [
    "workspace 2 silent, class:(librewolf)"
    "workspace 3 silent, class:(KeePassXC)"
    "workspace 4 silent, class:((V|v)encord(D|d)esktop)"
    "workspace 4 silent, class:((V|v)esktop)"
    "workspace 5 silent, class:((F|f)erdium)"
    "workspace 6 silent, class:((S|s)team)"
    "workspace 6 silent, title:((S|s)team)"
    "float,              title:((S|s)team (S|s)ettings)"
    "workspace 10 silent, class:(Spotify)"

    # Browser screen sharing indicator
    "move 50% 100%-32,    title:^(.*— Sharing Indicator)"
    "minsize 52 32,       title:^(.*— Sharing Indicator)"
    "float,               title:^(.*— Sharing Indicator)"
    "fakefullscreen,      title:^(.*— Sharing Indicator)"
    "nofullscreenrequest, title:^(.*— Sharing Indicator)"
    "noinitialfocus,      title:^(.*— Sharing Indicator)"
    "noborder,            title:^(.*— Sharing Indicator)"

    # CopyQ
    "float,  class:(com\\.github\\.hluk\\.copyq)"
    "center, class:(com\\.github\\.hluk\\.copyq)"

    # OnlyOffice
    "tile, class:(DesktopEditors)"

    # Mega
    "float, class:(nz\\.co\\.mega\\.)"

    # mpv
    "monitor $mon1, class:(mpv)"
    "fullscreen,    class:(mpv)"

    # nsxiv
    "tile, class:(Nsxiv)"

    # qBitTorrent
    "monitor $mon2,   class:(org\\.qbittorrent\\.qBittorrent)"
    "workspace empty silent, class:(org\\.qbittorrent\\.qBittorrent) title:^(qBittorrent v([0-9]\\.){2}[0-9])$"

    # Wofi
    "float,       class:(wofi)"
    "center,      class:(wofi)"
    "stayfocused, class:(wofi)"
    "rounding 10, class:(wofi)"
    "noborder,    class:(wofi)"
    "pin,         class:(wofi)"
    "dimaround,   class:(wofi)"

    # XWaylandVideoBridge
    "opacity 0.0 override 0.0 override, class:^(xwaylandvideobridge)$"
    "noanim,                            class:^(xwaylandvideobridge)$"
    "nofocus,                           class:^(xwaylandvideobridge)$"
    "noinitialfocus,                    class:^(xwaylandvideobridge)$"
  ] ++ builtins.foldl'
    (acc: game: acc ++ [
      "monitor $mon1, ${game}"
      "workspace 9,   ${game}"
    ])
    [ ]
    [
      "class:(steam_app.*)" # Steam games
      "class:(factorio)"
      "class:(cs2)"
      "title:(shapez)"
    ];

  layerrule = [
    "blur,       waybar"
    "ignorezero, waybar"
  ];

  bind = [
    "${modKey},         T, exec, kitty"
    "${modKey},         W, exec, $BROWSER"
    "${modKey} SHIFT,   W, exec, $BROWSER_PRIV"
    "${modKey} CONTROL, W, exec, $BROWSER_PROF"
    "${modKey},         C, exec, copyq show"
    "${modKey},         E, exec, pcmanfm"

  ] ++ (if config.modules.rofi.enable then [
    "${modKey},       D,      exec, rofi -show drun -prompt ''"
    "${modKey} SHIFT, D,      exec, rofi -show run  -prompt ''"
    "${modKey},       ESCAPE, exec, rofi -show p -no-show-icons -modi p:rofi-power-menu"
  ]
  else if config.modules.wofi.enable then [
    "${modKey},       D, exec, wofi --show drun --prompt ''"
    "${modKey} SHIFT, D, exec, wofi --show run  --prompt ''"
  ]
  else [ ]
  ) ++ lib.optional config.modules.power-menu.enable "${modKey}, ESCAPE, exec, power-menu" ++ [
    "${modKey}, PRINT, exec, hyprshot -m window"
    ",          PRINT, exec, hyprshot -m region"

    "${modKey}, X, exec, ${swaylock}"

    "${modKey} SHIFT,   Q, killactive,"
    "${modKey} CONTROL, V, pseudo," # dwindle
    "${modKey},         V, togglesplit," # dwindle
    "${modKey} SHIFT,   V, togglefloating,"

    "${modKey},       F, fullscreen"
    "${modKey} SHIFT, F, fakefullscreen"

    "${modKey}, N, movecurrentworkspacetomonitor, -1"
    "${modKey}, M, swapactiveworkspaces, -1 current"

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
  ] ++
  (lib.mapAttrsToList (key: name:      "${modKey},       ${key}, workspace,             ${name}") workspaces) ++
  (lib.mapAttrsToList (key: name:      "${modKey} SHIFT, ${key}, movetoworkspacesilent, ${name}") workspaces) ++
  (lib.mapAttrsToList (key: direction: "${modKey},       ${key}, movefocus,             ${direction}") directionsHJKL) ++
  (lib.mapAttrsToList (key: direction: "${modKey} SHIFT, ${key}, movewindow,            ${direction}") directionsHJKL);

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

  bindl = ", switch:on:Lid Switch, exec, ${swaylock}";
}
  //
(
  let
    genDeviceConfig = (acc: d: acc // { "device:logitech-g903-${d}" = { sensitivity = -0.93; }; });
    devices = [
      "lightspeed-wireless-gaming-mouse-w/-hero"
      "lightspeed-wireless-gaming-mouse-w/-hero-1"
      "lightspeed-wireless-gaming-mouse-w/-hero-2"
      "ls-1"
    ];
  in
  builtins.foldl' genDeviceConfig { } devices
)
