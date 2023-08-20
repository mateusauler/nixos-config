{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.fish;
  inherit (lib) mkDefault;
in {
  options.modules.fish = {
    enable = lib.mkEnableOption "fish";
    pfetch.enable = lib.mkEnableOption "pfetch";
    exa.enable = lib.mkEnableOption "exa";
  };

  config = lib.mkIf cfg.enable {
    modules.fish = pkgs.lib.my.enableModules { module-names = [ "pfetch" "exa" ]; };
    home.packages = lib.mkIf cfg.pfetch.enable [ pkgs.pfetch ];

    programs = {
      exa.enable = cfg.exa.enable;
      fish = {
        enable = true;
        shellAliases = (import ../shell-aliases.nix { inherit config; });
        shellAbbrs = (import ./abbreviations.nix { inherit custom; });

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
