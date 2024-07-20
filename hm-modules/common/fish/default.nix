{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.fish;
  inherit (lib) mkEnableOption mkOption;
  inherit (pkgs.lib) mkTrueEnableOption;
in
{
  options.modules.fish = {
    enable = mkEnableOption "fish";
    pfetch.enable = mkEnableOption "pfetch";
    ondir.enable = mkEnableOption "ondir";
    functions =
      with lib.types;
      mkOption {
        type = attrsOf (submodule {
          options = {
            enable = mkTrueEnableOption null;
            path = mkOption { type = path; };
          };
        });
        # TODO: User should declare this as `default.default = ./functions`
        # default.default.path = ./functions;
        default = { };
      };
  };

  imports = [ ./abbreviations.nix ];

  config = lib.mkIf cfg.enable {
    home.packages = lib.flatten [
      (lib.optional cfg.pfetch.enable pkgs.pfetch)
      (lib.optional cfg.ondir.enable pkgs.ondir)
    ];

    modules.fish.functions.default.path = lib.mkDefault ./functions;

    programs.fish = {
      enable = true;
      shellAliases = config.shell-aliases;

      interactiveShellInit = lib.strings.optionalString cfg.pfetch.enable "pfetch";

      shellInit = # fish
        ''
          set fish_greeting
          fish_vi_key_bindings
          ${lib.optionalString cfg.ondir.enable "ondir_prompt_hook"}
        '';
    };

    # The `fish_variables` file includes all of the abbreviations and some other variables that I don't care about.
    # So, if an abbreviation is removed in the config, it will still exist in the fish_variables file.
    # Therefore, let's remove it.
    home.activation."remove-fish_variables" =
      lib.hm.dag.entryAfter [ "writeBoundary" ] # bash
        ''
          $DRY_RUN_CMD rm -f $VERBOSE_ARG ${config.xdg.configHome}/fish/fish_variables
        '';

    xdg.configFile =
      (
        let
          # Finds all of the functions in a given directory
          readFiles = p: lib.filterAttrs (_: type: type == "regular") (builtins.readDir p);

          # Transforms a given set into the format { "fish/functions/..." = ...; }
          mapToXdgFile =
            p: name: _:
            lib.nameValuePair "fish/functions/${name}" { source = "${p}/${name}"; };

          # Maps all found files in path `p` into xdg sets
          pathToXdgFileSet = p: lib.mapAttrs' (mapToXdgFile p) (readFiles p);

          # Filter enabled fish functions
          enabledFunctions = lib.filterAttrs (_: { enable, ... }: enable) cfg.functions;

          # Map configured fish functions into the format { name = path; }
          enabledPathSets = lib.mapAttrs (_: { path, ... }: path) enabledFunctions;

          # List of all enabled paths
          enabledPaths = lib.attrValues enabledPathSets;
        in
        # Turn enabled fish function paths into xdg file sets of files found in them
        lib.foldl (acc: p: acc // (pathToXdgFileSet p)) { } enabledPaths
      )
      // {
        "fish/functions/ondir_prompt_hook.fish" = {
          enable = cfg.ondir.enable;
          text = # fish
            ''
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
