{
  "layer" = "top"; # Waybar at top layer
  "height" = 30; # Waybar height (to be removed for auto height)
  "spacing" = 8; # Gaps between modules

  "modules-left" = [
    "wlr/workspaces"
    "sway/mode"
    "sway/scratchpad"
    "custom/media"
    "hyprland/window"
  ];
  "modules-center" = [
    "clock"
  ];
  "modules-right" = [
    # "mpd"
    "idle_inhibitor"
    "pulseaudio"
    "network"
    "cpu"
    "memory"
    "temperature"
    # "backlight"
    "keyboard-state"
    # "hyprland/language"
    # "battery"
    # "battery#bat2"
    "tray"
  ];

  # Modules configuration
  "hyprland/window" = {
    "max-length" = 200;
    "separate-outputs" = true;
    "format" = "{title}";
  };
  "wlr/workspaces" = {
    "disable-scroll" = false;
    "on-click" = "activate";
    #     "all-outputs" = true;
    #     "warp-on-scroll" = false;
    #     "format" = "{icon}  {name}";
    #     "format-icons" = {
    #         "1" = " ";
    #         "2" = " ";
    #         "3" = " ";
    #         "4" = " ";
    #         "5" = " ";
    #         "urgent" = " ";
    #         "focused" = " ";
    #         "default" = " "
    "on-scroll-up" = "hyprctl dispatch workspace m+1";
    "on-scroll-down" = "hyprctl dispatch workspace m-1";
    "sort-by-number" = true;
  };
  "keyboard-state" = {
    "numlock" = true;
    "capslock" = true;
    "format" = "{name} {icon}";
    "format-icons" = {
      "locked" = "";
      "unlocked" = "";
    };
  };
  "sway/mode" = {
    "format" = "<span style=\"italic\">{}</span>";
  };
  "sway/scratchpad" = {
    "format" = "{icon} {count}";
    "show-empty" = false;
    "format-icons" = [
      "  " " "
    ];
    "tooltip" = true;
    "tooltip-format" = "{app} = {title}";
  };
  "mpd" = {
    "format" = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}%  ";
    "format-disconnected" = "Disconnected  ";
    "format-stopped" = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon} Stopped   ";
    "unknown-tag" = "N/A";
    "interval" = 2;
    "consume-icons" = {
      "on" = " ";
    };
    "random-icons" = {
      "off" = "<span color=\"#f53c3c\"></span> ";
      "on" = " ";
    };
    "repeat-icons" = {
      "on" = " ";
    };
    "single-icons" = {
      "on" = " 1";
    };
    "state-icons" = {
      "paused" = " ";
      "playing" = " ";
    };
    "tooltip-format" = "MPD (connected)";
    "tooltip-format-disconnected" = "MPD (disconnected)";
  };
  "idle_inhibitor" = {
    "format" = "{icon}";
    "format-icons" = {
      "activated" = "";
      "deactivated" = "";
    };
  };
  "tray" = {
    # "icon-size" = 21;
    "spacing" = 10;
  };
  "clock" = {
    "format" = "  {:%H:%M:%S    %a %Y-%m-%d}";
    "format-alt" = "  {:%H:%M    %a %Y-%m-%d}";
    "interval" = 1;

    "tooltip-format" = "<big>{:%Y}</big>\n\n<tt><small>{calendar}</small></tt>";
    "calendar" = {
      "mode" = "month";
      "mode-mon-col" = 3;
      "on-scroll" = 1;
      "format" = {
        "months" =   "<span color='#ffead3'><b>{}</b></span>";
        "days" =     "<span color='#ecc6d9'><b>{}</b></span>";
        "weeks" =    "<span color='#99ffdd'><b>W{}</b></span>";
        "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
        "today" =    "<span color='#ff6699'><b><u>{}</u></b></span>";
      };
    };
    "actions" =  {
      "on-click-right" = "mode";
      "on-click-forward" = "tz_up";
      "on-click-backward" = "tz_down";
      "on-scroll-up" = "shift_up";
      "on-scroll-down" = "shift_down";
    };
  };
  "cpu" = {
    "format" = "{usage}% ";
    "tooltip" = false;
    "interval" = 2;
  };
  "memory" = {
    "format" = "{}% ";
  };
  "temperature" = {
    # "thermal-zone" = 2;
    "hwmon-path" = "/sys/class/hwmon/hwmon2/temp1_input";
    "critical-threshold" = 80;
    # "format-critical" = "{temperatureC}°C {icon}";
    "format" = "{temperatureC}°C {icon}";
    "format-icons" = [
      "" "" ""
    ];
    "interval" = 3;
  };
  "backlight" = {
    # "device" = "acpi_video1";
    "format" = "{percent}% {icon}";
    "format-icons" = [
      "" "" "" "" "" "" "" "" ""
    ];
  };
  "battery" = {
    "states" = {
      # "good" = 95;
      "warning" = 30;
      "critical" = 15;
    };
    "format" = "{capacity}% {icon}";
    "format-charging" = "{capacity}% ";
    "format-plugged" = "{capacity}% ";
    "format-alt" = "{time} {icon}";
    # "format-good" = ""; # An empty format will hide the module
    # "format-full" = "";
    "format-icons" = [
      "" "" "" "" ""
    ];
  };
  "battery#bat2" = {
    "bat" = "BAT2";
  };
  "network" = {
    # "interface" = "wlp2*"; # (Optional) To force the use of this interface
    "format-wifi" = "{essid} ({signalStrength}%) ";
    "format-ethernet" = "{ipaddr}/{cidr} ";
    "tooltip-format" = "{ifname} via {gwaddr} ";
    "format-linked" = "{ifname} (No IP) ";
    "format-disconnected" = "Disconnected ⚠";
    "format-alt" = "{ifname} = {ipaddr}/{cidr}";
  };
  "pulseaudio" = {
    # "scroll-step" = 1; # %; can be a float
    "format" = "{icon} {volume}% | {format_source}";
    "format-bluetooth" = "{volume}% {icon} {format_source}";
    "format-bluetooth-muted" = " {icon} {format_source}";
    "format-muted" = " {format_source}";
    "format-source" = "{volume}% ";
    "format-source-muted" = "";
    "format-icons" = {
      "headphone" = " ";
      "hands-free" = " ";
      "headset" = " ";
      "phone" = " ";
      "portable" = " ";
      "car" = " ";
      "default" = [ " " " " " " ];
    };
    "on-click" = "pavucontrol";
  };
  "custom/media" = {
    "format" = "{icon} {}";
    "return-type" = "json";
    "max-length" = 40;
    "format-icons" = {
        "spotify" = " ";
        "default" = "🎜 ";
    };
    "escape" = true;
    "exec" = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null"; # Script in resources folder
    # "exec" = "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null"; # Filter player based on name
  };
}