{
  # env = XCURSOR_SIZE,24
  # env = QT_QPA_PLATFORM,wayland
  # env = GTK_THEME,Nord
  # env = QT_QPA_PLATFORMTHEME,gtk

  exec-once = [ "kitty" ];

  input = {
    # TODO: Use globally configured layout
    kb_layout = "br";

    repeat_rate = 50;
    repeat_delay = 400;

    follow_mouse = 1;
    float_switch_override_focus = 0;

    touchpad = {
      natural_scroll = false;
    };

    accel_profile = "flat";
  };

  general = {
    gaps_in = 5;
    gaps_out = 20;
    border_size = 3;

    # TODO: Use nix-colors
    "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
    "col.inactive_border" = "rgba(595959aa)";

    layout = "dwindle";
    cursor_inactive_timeout = 2;
  };

  decoration = {
    rounding = 5;
    #blur = yes
    #blur_size = 3
    #blur_passes = 1
    # blur_new_optimizations = on

    drop_shadow = true;
    shadow_range = 4;
    shadow_render_power = 3;
    "col.shadow" = "rgba(1a1a1aee)";

    dim_special = "0.4";
  };

  animations = {
    enabled = true;

    bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

    animation = [
      "windows, 1, 5, myBezier"
      "windowsOut, 1, 7, default, popin 80%"
      "border, 1, 10, default"
      "borderangle, 1, 8, default"
      "fade, 1, 7, default"
      "workspaces, 1, 4, default"
    ];
  };

  dwindle = {
    pseudotile = true;
    preserve_split = true;
  };

  master = {
    new_is_master = true;
  };

  gestures = {
    workspace_swipe = false;
  };

  misc = {
    vrr = 2;
    disable_splash_rendering = true;
    animate_manual_resizes = true;
    animate_mouse_windowdragging = true;
    disable_hyprland_logo = true;
    background_color = "0x000000";
  };

  binds = {
    scroll_event_delay = 80;
  };

  windowrulev2 = [
    "move 50% 100%-32, title:^(.*— Sharing Indicator)"
    "minsize 52 32, title:^(.*— Sharing Indicator)"
    "float, title:^(.*— Sharing Indicator)"
    "fakefullscreen, title:^(.*— Sharing Indicator)"
    "nofullscreenrequest, title:^(.*— Sharing Indicator)"
    "noinitialfocus, title:^(.*— Sharing Indicator)"
    "noborder, title:^(.*— Sharing Indicator)"

    "float, class:(Rofi)"
    "center, class:(Rofi)"
    "stayfocused, class:(Rofi)"

    "float, class:(com\.github\.hluk\.copyq)"
    "center, class:(com\.github\.hluk\.copyq)"

    "float, class:(MEGAsync)"

    "tile, class:(Nsxiv)"

    "workspace 2 silent, class:(librewolf)"
    "workspace 3 silent, class:(KeePassXC)"
    "workspace 4 silent, class:((F|f)erdium)"
    "workspace 5 silent, class:((S|s)team)"
    "workspace 5 silent, title:((S|s)team)"
    "workspace 10 silent, class:(Spotify)"

    "monitor $mon1, class:(mpv)"
    "fullscreen, class:(mpv)"

    "monitor $mon2, class:(org\.qbittorrent\.qBittorrent)"
    # Should be workspace empty silent, but there is a bug
    "workspace empty, class:(org\.qbittorrent\.qBittorrent) title:^(qBittorrent v([0-9]\.){2}[0-9])$"

    "fakefullscreen, class:(csgo_linux64)"
    "monitor $mon1, class:(csgo_linux64)"
    "tile, class:(csgo_linux64)"
    "workspace empty, class:(csgo_linux64)"
  ];

  "$mainMod" = "SUPER";

  bind = [
    "$mainMod, T, exec, kitty"
    "$mainMod, W, exec, $BROWSER"
    "$mainMod SHIFT, W, exec, $BROWSER_PRIV"
    "$mainMod CONTROL, W, exec, $BROWSER_PROF"
    "$mainMod, C, exec, copyq show"
    "$mainMod, E, exec, pcmanfm"
    "$mainMod, D, exec, rofi -show drun"
    "$mainMod SHIFT, D, exec, rofi -show run"
    "$mainMod, ESCAPE, exec, rofi -no-show-icons -show p -modi p:rofi-power-menu"

    "$mainMod, PRINT, exec, hyprshot -m window"
    ", PRINT, exec, hyprshot -m region"

    "$mainMod SHIFT, Q, killactive, "
    "$mainMod, P, pseudo, # dwindle"
    "$mainMod, V, togglesplit, # dwindle"
    "$mainMod SHIFT, V, togglefloating, "

    "$mainMod, F, fullscreen"
    "$mainMod SHIFT, F, fakefullscreen"

    # Move focus with mainMod + (H|J|K|L)
    "$mainMod, H, movefocus, l"
    "$mainMod, L, movefocus, r"
    "$mainMod, K, movefocus, u"
    "$mainMod, J, movefocus, d"

    "$mainMod SHIFT, H, movewindow, l"
    "$mainMod SHIFT, L, movewindow, r"
    "$mainMod SHIFT, K, movewindow, u"
    "$mainMod SHIFT, J, movewindow, d"

    "$mainMod, N, movecurrentworkspacetomonitor, -1"
    "$mainMod, M, swapactiveworkspaces, -1 current"

    # Switch workspaces with mainMod + [0-9]
    "$mainMod, 1, workspace, 1"
    "$mainMod, 2, workspace, 2"
    "$mainMod, 3, workspace, 3"
    "$mainMod, 4, workspace, 4"
    "$mainMod, 5, workspace, 5"
    "$mainMod, 6, workspace, 6"
    "$mainMod, 7, workspace, 7"
    "$mainMod, 8, workspace, 8"
    "$mainMod, 9, workspace, 9"
    "$mainMod, 0, workspace, 10"

    "$mainMod, R, workspace, empty"
    "$mainMod, TAB, workspace, previous"

    "$mainMod,       COMMA,  focusmonitor,     -1"
    "$mainMod SHIFT, COMMA,  movewindow,   mon:-1"
    "$mainMod,       PERIOD, focusmonitor,     +1"
    "$mainMod SHIFT, PERIOD, movewindow,   mon:+1"

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
    "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
    "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
    "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
    "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
    "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
    "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
    "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
    "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
    "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
    "$mainMod SHIFT, 0, movetoworkspacesilent, 10"

    "$mainMod SHIFT, S, movetoworkspacesilent, special"
    "$mainMod SHIFT, S, movetoworkspacesilent, m+0"
    "$mainMod, S, togglespecialworkspace"

    "$mainMod SHIFT, R, movetoworkspacesilent, empty"

    # Scroll through existing workspaces on the same monitor with mainMod + scroll
    "$mainMod, mouse_down, workspace, m+1"
    "$mainMod, mouse_up, workspace, m-1"
  ];

  binde = [
    "$mainMod CONTROL, H, resizeactive, -50 0"
    "$mainMod CONTROL, L, resizeactive, 50 0"
    "$mainMod CONTROL, K, resizeactive, 0 -50"
    "$mainMod CONTROL, J, resizeactive, 0 50"
  ];

  # Move/resize windows with mainMod + LMB/RMB and dragging
  bindm = [
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
  ];
}
//
(
  let
    genDeviceConfig = (acc: d: acc // { "device:logitech-g903-${d}" = { sensitivity = -0.93; }; } );
    devices = [ "lightspeed-wireless-gaming-mouse-w/-hero-1"
                "lightspeed-wireless-gaming-mouse-w/-hero-2"
                "ls-1" ];
  in
    builtins.foldl' genDeviceConfig { } devices
)
