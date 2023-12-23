{ custom, ... }:

let
  inherit (custom) dots-path;
in
rec {
  mn = "udisksctl mount -b";
  um = "udisksctl unmount -b";

  g = "git";

  gs = "git status";
  gu = "git push";
  gp = "git pull";
  ga = "git add";
  gap = "git add -p";
  gc = "git commit";
  gca = "git commit --amend";
  gcaa = "git commit --amend -a";
  gh = "git checkout";
  ghb = "git checkout -b";
  gb = "git branch";
  gl = "git log";
  gsh = "git show";
  gd = "git diff";
  gdc = "git diff --cached";
  gg = "git grep";
  ggi = "git grep -i";
  gr = "git rebase";
  gri = "git rebase -i";
  gf = "git fetch";
  gm = "git merge";
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
