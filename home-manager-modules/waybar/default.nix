{ config, lib, pkgs, ... }:

let
  cfg = config.modules.waybar;
  inherit (pkgs.lib) colorToRgba;
in {
  options.modules.waybar = {
    enable = lib.mkEnableOption "waybar";
    battery.enable = lib.mkEnableOption "battery";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.pavucontrol ];
    programs.waybar = rec {
      enable = true;
      settings.mainBar = (import ./settings.nix) { inherit lib; config = cfg; };
      style = with config.colorScheme.colors; ''
        * {
            font-family: FontAwesome, Roboto, Helvetica, Arial, sans-serif;
            font-size: 13px;
        }

        window#waybar {
            background-color: ${colorToRgba base01 0.8};
            color: #${base04};
            transition: box-shadow .5s;
        }

        window#waybar.hidden {
            opacity: 0.2;
        }

        button {
            /* Use box-shadow instead of border so the text isn't offset */
            box-shadow: inset 0 -3px transparent;
            /* Avoid rounded borders under each button name */
            border: none;
            border-radius: 0;
        }

        /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
        button:hover {
            background: inherit;
            box-shadow: inset 0 -3px #${base04};
        }

        #workspaces button {
            padding: 0 5px;
            background-color: transparent;
            color: #${base04};
        }

        #workspaces button:hover {
            background: rgba(0, 0, 0, 0.2);
        }

        #workspaces button.active {
            background-color: #${base03};
            box-shadow: inset 0 -3px #${base04};
            transition: box-shadow .5s, background-color .5s;
        }

        #workspaces button:not(.active) {
            transition: box-shadow .5s, background-color .5s;
        }

        #workspaces button.urgent {
            background-color: #${base08};
        }

        #mode {
            background-color: #${base03};
            border-bottom: 3px solid #${base04};
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #pulseaudio,
        #wireplumber,
        #custom-media,
        #tray,
        #mode,
        #idle_inhibitor,
        #scratchpad,
        #mpd,
        #keyboard-state {
            padding: 0 10px;
            color: #${base04};
            border-bottom: 3px solid #${base05};
        }

        #window,
        #workspaces {
            margin: 0 4px;
        }

        #window {
            box-shadow: inset 0 -3px #${base05};
            transition: box-shadow .5s, color .5s;
        }

        window#waybar.empty #window {
            color: transparent;
            box-shadow: none;
            transition: none;
        }

        /* If workspaces is the leftmost module, omit left margin */
        .modules-left > widget:first-child > #workspaces {
            margin-left: 0;
        }

        /* If workspaces is the rightmost module, omit right margin */
        .modules-right > widget:last-child > #workspaces {
            margin-right: 0;
        }

        /*
         * Hacky way to ensure that there is a gap arround the center modules,
         * if the screen is too small.
         */
        .modules-center {
            margin-right: ${toString settings.mainBar.spacing}px;
            margin-left: ${toString settings.mainBar.spacing}px;
        }

        @keyframes blink {
            to {
                background-color: #${base04};
                color: #${base00};
            }
        }

        #battery.critical:not(.charging) {
            background-color: #${base08};
            color: #${base04};
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        label:focus {
            background-color: #${base00};
        }

        #tray > .passive {
            -gtk-icon-effect: dim;
        }

        #language {
            padding: 0 5px;
            margin: 0 5px;
            min-width: 16px;
        }

        #keyboard-state {
            padding: 0 10px 0 5px;
        }

        #keyboard-state > label {
            padding: 0 5px;
        }

        #keyboard-state > label.locked {
            background: #${base08};
        }
      '';
    };
  };
}
