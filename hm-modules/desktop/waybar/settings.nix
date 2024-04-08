{ config, lib, ... }:

let
  cfg = config.modules.waybar;
in
lib.mkIf cfg.enable {
  programs.waybar.settings.mainBar = {
    layer   = "top";
    height  = 30;
    spacing = 8;

    modules-left = [
      "hyprland/workspaces"
      "hyprland/window"
    ];

    modules-center = [
      "clock"
    ];

    modules-right = lib.flatten [
      "mpris"
      "pulseaudio"
      "network"
      "cpu"
      "memory"
      "temperature"
      "keyboard-state"
      (lib.optional cfg.battery.enable "battery")
      "tray"
    ];

    # Modules configuration
    "hyprland/window" = {
      max-length = 200;
      separate-outputs = true;
      format = "{title}";
    };

    "hyprland/workspaces" = {
      disable-scroll = false;
      on-click = "activate";
      on-scroll-up   = "hyprctl dispatch workspace m+1";
      on-scroll-down = "hyprctl dispatch workspace m-1";
      sort-by-number = true;
    };

    keyboard-state = {
      numlock = true;
      capslock = true;
      format = "{name} {icon}";
      format-icons = {
        locked   = "";
        unlocked = "";
      };
    };

    tray = {
      # icon-size = 21;
      spacing = 10;
    };

    clock = {
      format = "  {:%H:%M:%S    %a %d/%m/%Y}";
      interval = 1;

      tooltip-format = "<big>{:%Y}</big>\n\n<tt><small>{calendar}</small></tt>";
      calendar = {
        mode = "month";
        mode-mon-col = 3;
        on-scroll = 1;
        format = with config.colorScheme.palette; {
          months   = "<span color='#${base07}'><b>{}</b></span>";
          days     = "<span color='#${base05}'><b>{}</b></span>";
          weeks    = "<span color='#${base0C}'><b>W{}</b></span>";
          weekdays = "<span color='#${base06}'><b>{}</b></span>";
          today    = "<span color='#${base08}'><b><u>{}</u></b></span>";
        };
      };
      actions =  {
        on-click-right    = "mode";
        on-click-forward  = "tz_up";
        on-click-backward = "tz_down";
        on-scroll-up      = "shift_up";
        on-scroll-down    = "shift_down";
      };
    };

    cpu = {
      format = "{usage}% ";
      tooltip = false;
      interval = 1;
    };

    memory = {
      format = "{}% ";
    };

    temperature = {
      # thermal-zone = 2;
      hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
      critical-threshold = 80;
      format = "{temperatureC}°C {icon}";
      format-icons = [
        "" "" "" "" ""
      ];
      interval = 1;
    };

    battery = {
      states = {
        warning = 30;
        critical = 15;
      };
      format          = "{capacity}% {icon}";
      format-charging = "{capacity}% ";
      format-plugged  = "{capacity}% ";
      format-alt      = "{time} {icon}";
      format-icons    = [ "" "" "" "" "" ];
    };

    "battery#bat2" = {
      bat = "BAT2";
    };

    network = {
      format-wifi         = "{essid} ({signalStrength}%) ";
      format-ethernet     = "{ipaddr}/{cidr} ";
      tooltip-format      = "{ifname} via {gwaddr} ";
      format-linked       = "{ifname} (No IP) ";
      format-disconnected = "Disconnected ⚠";
      format-alt          = "{ifname}: {ipaddr}/{cidr}";
      interval            = 5;
    };

    mpris = {
      format        = "{dynamic}  {player_icon}";
      format-paused = "{dynamic}  {status_icon}";
      player-icons = {
        default = "";
        mpv     = "";
        spotify = "";
      };
      status-icons.paused = "";
      dynamic-order = [
        "title"
        "artist"
      ];
    };

    pulseaudio = {
      format                 = "{icon}  {volume}% {format_source}";
      format-bluetooth       = "{volume}% {desc} {format_source}";
      format-bluetooth-muted = " {desc} {format_source}";
      format-muted           = " {format_source}";
      format-source          = "| {volume}% ";
      format-source-muted    = "| ";
      format-icons = {
        headphone  = "";
        hands-free = "";
        headset    = "";
        phone      = "";
        portable   = "";
        car        = "";
        default    = [ "" "" "" ];
      };
      on-click = "pavucontrol";
      ignored-sinks = [ "Easy Effects Sink" ];
    };
  };
}
