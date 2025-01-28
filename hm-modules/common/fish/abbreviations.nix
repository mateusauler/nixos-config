{ config, lib, ... }:

let
  cfg = config.modules.fish;
  dots-path = with config.dots; if clone then path else nix-uri;
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

      nrb = "nixos-rebuild --verbose --flake ${dots-path} --show-trace build";
      nrs = "sudo nixos-rebuild --verbose --flake ${dots-path} switch";
      nrt = "sudo nixos-rebuild --verbose --flake ${dots-path} test";
      nrbt = "sudo nixos-rebuild --verbose --flake ${dots-path} boot";

      nrbf = "${nrb} --fast";
      nrsf = "${nrs} --fast";
      nrtf = "${nrt} --fast";
      nrbtf = "${nrbt} --fast";

      nfc = "nix flake check --verbose --show-trace";

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
    // lib.optionalAttrs config.programs.lazygit.enable { lg = "lazygit"; };
}
