{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.git;
in
{
  options.modules.git = with lib; {
    gpgKey = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    lazygit = pkgs.lib.mkTrueEnableOption "Lazygit";
    wt = pkgs.lib.mkTrueEnableOption "Git Worktree Switcher";
  };

  imports = [ ./wt.nix ];

  config = {
    programs.lazygit.enable = cfg.lazygit;
    programs.git = {
      enable = true;
      lfs.enable = true;
      userName = "Mateus Auler";
      userEmail = "mateusauler@protonmail.com";
      ignores = [
        # (n)vim
        "*.swp"
        ".exrc"
        ".nvimrc"

        # Direnv
        ".direnv/"

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
        rebase.autostash = true;
        push.autoSetupRemote = true;
        submodule.recurse = true;
        advice = {
          addEmptyPathspec = false;
          addIgnoredFile = false;
        };
        init.defaultBranch = "master";
        mergetool.keepBackup = false;
      };
    };
  };
}
