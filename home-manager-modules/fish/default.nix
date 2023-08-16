{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.fish;
  inherit (lib) mkDefault;
in {
  options.modules.fish.enable = lib.mkEnableOption "fish";

  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      shellAliases = import ../shell-aliases.nix;
      shellAbbrs = import ./abbreviations.nix;

      loginShellInit = ''
        if [ -z "$DISPLAY" ] && test (tty) = "/dev/tty1";
          lsmod | grep pcspkr > /dev/null && sudo rmmod pcspkr &
          ${if config.modules.hyprland.enable then "Hyprland" else ""}
        end'';

      interactiveShellInit = "type -q pfetch && pfetch";

      shellInit = ''
        set fish_greeting
        fish_vi_key_bindings
      '';
    };

    xdg.configFile = {
      "fish/functions" = {
        source = ./functions;
        recursive = true;
      };
    };
  };
}