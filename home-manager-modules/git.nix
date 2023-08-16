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
      signing.key = if cfg.gpgKey != null then cfg.gpgKey else "";
      extraConfig = {
        pull.rebase = "true";
        push.autoSetupRemote = "true";
        submodule.recurse = "true";
      };
    };
  };
}
