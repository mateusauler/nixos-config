{ config, lib, ... }:

let
  cfg = config.modules.hyprland;
  workspaces = (lib.attrsets.genAttrs (map toString (lib.range 1 9)) (name: name)) // { "0" = "10"; };
  directionsArrows = { left = "l"; right = "r"; up = "u"; down = "d"; };
  directionsHJKL   = { H    = "l"; L     = "r"; K  = "u"; J    = "d"; };
  inherit (cfg) modKey;
in {
  exec-once = [ "kitty" ];

  input = {
    # TODO: Use globally configured layout
    kb_layout = "br";

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

    animate_manual_resizes       = true;
    animate_mouse_windowdragging = true;

    disable_splash_rendering = true;
    disable_hyprland_logo    = true;
    background_color         = "0x000000";
  };

  binds.scroll_event_delay = 80;

  windowrulev2 = [
    "move 50% 100%-32,    title:^(.*— Sharing Indicator)"
    "minsize 52 32,       title:^(.*— Sharing Indicator)"
    "float,               title:^(.*— Sharing Indicator)"
    "fakefullscreen,      title:^(.*— Sharing Indicator)"
    "nofullscreenrequest, title:^(.*— Sharing Indicator)"
    "noinitialfocus,      title:^(.*— Sharing Indicator)"
    "noborder,            title:^(.*— Sharing Indicator)"

    "float,       class:(wofi)"
    "center,      class:(wofi)"
    "stayfocused, class:(wofi)"
    "rounding 0,  class:(wofi)"
    "noborder,    class:(wofi)"
    "pin,         class:(wofi)"

    "float,  class:(com\.github\.hluk\.copyq)"
    "center, class:(com\.github\.hluk\.copyq)"

    "float, class:(MEGAsync)"

    "tile, class:(Nsxiv)"

    "workspace 2 silent, class:(librewolf)"
    "workspace 3 silent, class:(KeePassXC)"
    "workspace 4 silent, class:((F|f)erdium)"
    "workspace 5 silent, class:((S|s)team)"
    "workspace 5 silent, title:((S|s)team)"
    "workspace name:0 silent, class:(Spotify)"

    "monitor $mon1, class:(mpv)"
    "fullscreen,    class:(mpv)"

    "monitor $mon2,   class:(org\.qbittorrent\.qBittorrent)"
    # Should be workspace empty silent, but there is a bug
    "workspace empty, class:(org\.qbittorrent\.qBittorrent) title:^(qBittorrent v([0-9]\.){2}[0-9])$"

    "fakefullscreen,  class:(csgo_linux64)"
    "monitor $mon1,   class:(csgo_linux64)"
    "tile,            class:(csgo_linux64)"
    "workspace empty, class:(csgo_linux64)"
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
        "${modKey},       D, exec, wofi --normal-window --show drun --prompt ''"
        "${modKey} SHIFT, D, exec, wofi --normal-window --show run  --prompt ''"
        # TODO: Create power menu using wofi
      ]
      else [ ]
    ) ++ [

    "${modKey}, PRINT, exec, hyprshot -m window"
    ",          PRINT, exec, hyprshot -m region"

    "${modKey} SHIFT, Q, killactive,"
    "${modKey},       P, pseudo," # dwindle
    "${modKey},       V, togglesplit," # dwindle
    "${modKey} SHIFT, V, togglefloating,"

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
}
//
(
  let
    genDeviceConfig = (acc: d: acc // { "device:logitech-g903-${d}" = { sensitivity = -0.93; }; } );
    devices = [
      "lightspeed-wireless-gaming-mouse-w/-hero-1"
      "lightspeed-wireless-gaming-mouse-w/-hero-2"
      "ls-1"
    ];
  in
    builtins.foldl' genDeviceConfig { } devices
)
