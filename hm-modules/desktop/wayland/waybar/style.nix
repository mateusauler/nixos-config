{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.lib) colorToRgba;
  inherit (config.programs.waybar.settings.mainBar) spacing;
  inherit (config.stylix) fonts opacity;
  cfg = config.modules.waybar;
  underline-size = "2px";
in
lib.mkIf cfg.enable {
  stylix.targets.waybar.enable = false;
  programs.waybar.style =
    with config.lib.stylix.colors;
    # css
    ''
      * {
        font-family: Symbols Nerd Font Mono, Arimo Nerd Font Propo;
        font-size: ${toString (fonts.sizes.desktop)}pt;
      }

      window#waybar {
        background-color: ${colorToRgba base00 opacity.desktop};
        color: #${base05};
        transition: box-shadow .5s;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      tooltip {
        background-color: #${base01};
        color: #${base05};
      }

      button {
        /* Use box-shadow instead of border so the text isn't offset */
        box-shadow: inset 0 ${underline-size} transparent;
        /* Avoid rounded borders under each button name */
        border: none;
        border-radius: 0;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #${base05};
        transition: box-shadow .5s, background-color .5s;
      }

      #workspaces button:hover {
        background: ${colorToRgba base03 (opacity.desktop * 1.2)};
      }

      #workspaces button.active {
        background-color: #${base03};
        box-shadow: inset 0 -${underline-size} #${base05};
      }

      #workspaces button.urgent {
        background-color: #${base08};
      }

      #mode {
        background-color: #${base03};
        border-bottom: ${underline-size} solid #${base05};
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
      #mpris,
      #mpd,
      #keyboard-state {
        padding: 0 10px;
        color: #${base05};
        border-bottom: ${underline-size} solid #${base05};
      }

      #window,
      #workspaces {
        margin: 0 4px;
      }

      #window {
        box-shadow: inset 0 -${underline-size} #${base05};
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
        margin-right: ${toString spacing}px;
        margin-left:  ${toString spacing}px;
      }

      @keyframes blink {
          to {
            background-color: #${base05};
            color: #${base00};
          }
      }

      #battery.critical:not(.charging) {
        background-color: #${base08};
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
        transition: background-color .3s;
      }

      #keyboard-state > label.locked {
        background: #${base08};
      }
    '';
}
