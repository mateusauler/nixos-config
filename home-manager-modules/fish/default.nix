{ config, lib, nix-colors, pkgs, ... }@args:

let
  cfg = config.modules.fish;
  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
  inherit (lib) mkDefault mkEnableOption;
  inherit (pkgs.lib) mkTrueEnableOption;
in
{
  options.modules.fish = {
    enable = mkEnableOption "fish";
    pfetch.enable = mkTrueEnableOption "pfetch";
    eza.enable = mkTrueEnableOption "eza";
    ondir.enable = mkEnableOption "ondir";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (lib.optional cfg.pfetch.enable pkgs.pfetch) ++ (lib.optional cfg.ondir.enable pkgs.ondir);

    programs = {
      eza.enable = cfg.eza.enable;
      fish = {
        enable = true;
        shellAliases = (import ../shell-aliases.nix args);
        shellAbbrs = (import ./abbreviations.nix args);

        interactiveShellInit = ''
          sh ${nix-colors-lib.shellThemeFromScheme { scheme = config.colorScheme; }}
          ${lib.strings.optionalString cfg.pfetch.enable "pfetch"}
        '';

        shellInit = ''
          set fish_greeting
          fish_vi_key_bindings
          ${lib.optionalString cfg.ondir.enable "ondir_prompt_hook"}
        '';
      };
    };

    # The `fish_variables` file includes all of the abbreviations and some other variables that I don't care about.
    # So, if an abbreviation is removed in the config, it will still exist in the fish_variables file.
    # Therefore, let's remove it.
    home.activation."remove-fish_variables" = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD rm -f $VERBOSE_ARG ${config.xdg.configHome}/fish/fish_variables
    '';

    xdg.configFile = {
      "fish/functions" = {
        source = ./functions;
        recursive = true;
      };
      "fish/functions/ondir_prompt_hook.fish" = {
        enable = cfg.ondir.enable;
        text = ''
          function ondir_prompt_hook --on-event fish_prompt
            if test ! -e "$OLDONDIRWD"; set -g OLDONDIRWD /; end
            echo "$PWD" > "/tmp/ondir-$USER-cd"
            eval (ondir $OLDONDIRWD $PWD)
            if test -f "/tmp/ondir-$USER-cd"
              cd (cat "/tmp/ondir-$USER-cd")
              rm "/tmp/ondir-$USER-cd"
            end
            set -g OLDONDIRWD "$PWD"
          end
        '';
      };
    };
  };
}
