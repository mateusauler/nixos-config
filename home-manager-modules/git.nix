{ config, lib, pkgs, ... }:

let
  cfg = config.modules.git;
in {
  options.modules.git = with lib; {
    gpgKey = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = {
    programs.git = {
      enable = true;
      userName = "Mateus Auler";
      userEmail = "mateusauler@protonmail.com";
      ignores = [
        # (n)vim
        "*.swp"
        ".exrc"
        ".nvimrc"

        # Direnv
        ".direnv/"
        ".envrc"

        # macOS
        ".DS_Store"

        # Emacs: backup, auto-save, lock files, directory-local
        # variables
        "*~"
        "\\#*\\#"
        ".\\#*"
        ".dir-locals.el"

        # vscode
        ".vscode/"
      ];
      signing.signByDefault = cfg.gpgKey != null;
      signing.key = lib.strings.optionalString (cfg.gpgKey != null) cfg.gpgKey;
      extraConfig = {
        pull.rebase = true;
        push.autoSetupRemote = true;
        submodule.recurse = true;
        advice = {
          addEmptyPathspec = false;
          addIgnoredFile = false;
        };
        init.defaultBranch = "master";
      };
    };
  };
}
