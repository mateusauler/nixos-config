{ config, lib, ... }:

let
  cfg = config.modules.fish;
  dots-path = with config.dots; if clone then path else nix-uri;

  nom-suffix = "--verbose --log-format internal-json 2>&1 | nom --json";
in
lib.mkIf cfg.enable {
  programs.fish.shellAbbrs =
    rec {
      # Git

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
      gc = "git commit";
      gdc = "git diff --cached";
      gd = "git diff";
      gf = "git fetch";
      gg = "git grep";
      ggi = "git grep -i";
      ghb = "git checkout -b";
      gh = "git checkout";
      gl = "git log";
      gll = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      glp = "git log -p";
      gm = "git merge";
      gmt = "git mergetool";
      gp = "git pull";
      gr = "git rebase";
      gra = "git rebase --abort";
      grc = "git rebase --continue";
      gri = "git rebase -i";
      gre = "git reset";
      grh = "git reset --hard";
      gs = "git status";
      gsh = "git show";
      gsd = "git stash drop";
      gsl = "git stash list";
      gsp = "git stash pop";
      gst = "git stash";
      gsu = "git stash -u";
      gu = "git push";
      gw = "git worktree";
      gwa = "git worktree add";
      gwl = "git worktree list";
      gwp = "git worktree prune";
      gwr = "git worktree remove";

      cg = "cd $(git rev-parse --show-toplevel 2> /dev/null || pwd | sed 's|/\\.git.*$||')";

      # Nix

      nrb = "nixos-rebuild --flake ${dots-path} --show-trace build ${nom-suffix}";
      nrs = "sudo true && sudo nixos-rebuild --flake ${dots-path} switch ${nom-suffix}";
      nrt = "sudo true && sudo nixos-rebuild --flake ${dots-path} test ${nom-suffix}";
      nrbt = "sudo true && sudo nixos-rebuild --flake ${dots-path} boot ${nom-suffix}";

      nfc = "nix flake check --show-trace ${nom-suffix}";

      # Utilities & common commands

      c = "cd";

      l = "ls";
      la = "ls -a";
      ll = "ls -l";
      lla = "ls -la";

      mn = "udisksctl mount -b";
      um = "udisksctl unmount -b";

      z = "zathura";

      n = "nvim";
      ni = "neovide";

      img = "nsxiv -a";
      im = img;

      md = "mkdir -p";

      hexdump = "hexdump -C";

      py = "python3";

      "!!" = {
        position = "anywhere";
        function = "last_history_item";
      };
    }
    // lib.optionalAttrs config.dots.clone { dots = "cd ${config.dots.path}"; }
    // lib.optionalAttrs config.programs.lazygit.enable { lg = "lazygit"; }
    // lib.optionalAttrs config.modules.jj.enable rec {
      j = "jj";

      ja = "jj abandon";
      jbd = "jj bookmark delete";
      jbf = "jj bookmark forget";
      jb = "jj bookmark";
      jbl = "jj bookmark list";
      jbm = "jj bookmark move --allow-backwards";
      jbmt = "${jbm} --from 'trunk()::@' --to $(jj log -r '::@ ~ empty()' -n 1 -T 'change_id' --no-graph)";
      jbs = "jj bookmark set";
      jc = "jj commit";
      jde = "jj diffedit";
      jdi = "jj diff";
      jd = "jj desc";
      je = "jj edit";
      jf = "jj git fetch";
      jg = "jj git";
      jl = "jj log";
      jlp = "jj log -p";
      jn = "jj new";
      jnt = "jj new 'trunk()'";
      jo = "jj op";
      jol = "jj op log";
      jor = "jj op restore";
      jpc = "jj git push --change @";
      jp = "jj git push";
      jpn = "jj git push --allow-new";
      jpt = "jj git push --tracked";
      jre = "jj resolve";
      jr = "jj rebase";
      jrl = "jj resolve -l";
      jrt = "jj rebase --destination 'trunk()'";
      jsh = "jj show";
      js = "jj status";
      jsp = "jj split";
      jsq = "jj squash";
      ju = "jj undo";

      cj = "cd $(jj root 2> /dev/null)";
    }
    // lib.optionalAttrs (with config.modules.jj; lazyjj && enable) {
      lj = "lazyjj";
    };
}
