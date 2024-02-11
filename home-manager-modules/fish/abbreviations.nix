{ config, ... }:

let
  inherit (config) dots-path;
in
rec {
  mn = "udisksctl mount -b";
  um = "udisksctl unmount -b";

  g = "git";

  ga = "git add";
  gaa = "git add -A";
  gap = "git add -p";
  gb = "git branch";
  gcaa = "git commit --amend -a";
  gca = "git commit --amend";
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
  gm = "git merge";
  gp = "git pull";
  gr = "git rebase";
  gri = "git rebase -i";
  gs = "git status";
  gsh = "git show";
  gsp = "git stash pop";
  gst = "git stash";
  gu = "git push";
  cg = "cd (git rev-parse --show-toplevel)";

  nrb = "nixos-rebuild --verbose --flake ${dots-path} --show-trace build";
  nrs = "sudo nixos-rebuild --verbose --flake ${dots-path} switch";
  nrt = "sudo nixos-rebuild --verbose --flake ${dots-path} test";
  nrbt = "sudo nixos-rebuild --verbose --flake ${dots-path} boot";

  nrbf = "${nrb} --fast";
  nrsf = "${nrs} --fast";
  nrtf = "${nrt} --fast";
  nrbtf = "${nrbt} --fast";

  nfc = "nix flake check --verbose --show-trace";

  dots = "cd ${dots-path}";

  z = "zathura";

  n = "nvim";
  ni = "neovide";

  img = "nsxiv -a";
  im = img;

  md = "mkdir -p";
  hexdump = "hexdump -C";

  py = "python3";
}
