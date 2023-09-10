{ config, lib, pkgs, ... }@args:

let
  cfg = config.modules.fish;
  inherit (lib) mkDefault;
  inherit (pkgs.lib) mkTrueEnableOption;
in {
  options.modules.fish = {
    enable = lib.mkEnableOption "fish";
    pfetch.enable = mkTrueEnableOption "pfetch";
    eza.enable = mkTrueEnableOption "eza";
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf cfg.pfetch.enable [ pkgs.pfetch ];

    programs = {
      eza.enable = cfg.eza.enable;
      fish = {
        enable = true;
        shellAliases = (import ../shell-aliases.nix args);
        shellAbbrs = (import ./abbreviations.nix args);

        loginShellInit = ''if [ -z "$DISPLAY" ] && test (tty) = "/dev/tty1";
                             lsmod | grep pcspkr > /dev/null && sudo rmmod pcspkr &
                             ${if config.modules.hyprland.enable then "Hyprland" else ""}
                           end'';

        interactiveShellInit = lib.mkIf cfg.pfetch.enable "pfetch";

        shellInit = ''set fish_greeting
                      fish_vi_key_bindings'';
      };
    };

    # This file includes all of the abbreviations and some other variables that I don't care about.
    # So, if an abbreviation is removed in the config, it will still exist in the fish_variables file.
    home.activation."remove-fish_variables" = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD rm -f $VERBOSE_ARG ${config.xdg.configHome}/fish/fish_variables
      '';

    xdg.configFile = {
      "fish/functions" = {
        source = ./functions;
        recursive = true;
      };
    };
  };
}
