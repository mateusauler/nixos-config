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
  };

  config = {
    shell-aliases = {
      gua = "git remote | sed '/^blacklist/{d}' | xargs -L1 git push --all";
      gsu = "git remote | sed '/^blacklist/{d}' | xargs -I {} git branch -u {}/$(git branch --show-current) $(git branch --show-current)";
    };

    programs = {
      git = {
        enable = true;
        lfs.enable = true;
        userName = "Mateus Auler";
        userEmail = "mateus@auler.dev";
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

      lazygit.enable = cfg.lazygit;
      git-worktree-switcher.enable = true;

      fish.shellAbbrs = {
        g = "git";

        gaa = "git add -A";
        ga = "git add";
        gap = "git add -p";
        gb = "git branch";
        gcaa = "git commit -a --amend";
        gcaan = "git commit -a --amend --no-edit";
        gca = "git commit -a";
        gcam = "git commit --amend";
        gcan = "git commit --amend --no-edit";
        gcb = "git checkout -b";
        gc = "git commit";
        gch = "git checkout";
        gdc = "git diff --cached";
        gd = "git diff";
        gf = "git fetch";
        gg = "git grep";
        ggi = "git grep -i";
        gl = "git log";
        gll = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        glp = "git log -p";
        gm = "git merge";
        gmt = "git mergetool";
        gp = "git pull";
        gra = "git rebase --abort";
        grc = "git rebase --continue";
        gre = "git reset";
        gr = "git rebase";
        grh = "git reset --hard";
        gri = "git rebase -i";
        gsd = "git stash drop";
        gs = "git status";
        gsh = "git show";
        gsl = "git stash list";
        gsp = "git stash pop";
        gst = "git stash";
        gsu = "git stash -u";
        gu = "git push";
        gwa = "git worktree add";
        gw = "git worktree";
        gwl = "git worktree list";
        gwp = "git worktree prune";
        gwr = "git worktree remove";

        cg = "cd $(git rev-parse --show-toplevel 2> /dev/null || pwd | sed 's|/\\.git.*$||')";

        lg = lib.mkIf cfg.lazygit "lazygit";
      };
    };
  };
}
