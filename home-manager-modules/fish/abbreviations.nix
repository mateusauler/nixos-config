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
  gl = "git pull";
  ga = "git add";
  gap = "git add -p";
  gc = "git commit";
  gca = "git commit --amend";
  gh = "git checkout";
  ghb = "${gh} -b";
  gb = "git branch";
  gd = "git diff";
  gdc = "git diff --cached";
  gg = "git grep";
  ggi = "git grep -i";
  cg = "cd (git rev-parse --show-toplevel)";

  nrb = "nixos-rebuild --verbose --flake ${dots-path} --show-trace build";
  nrs = "sudo nixos-rebuild --verbose --flake ${dots-path} switch";
  nrt = "sudo nixos-rebuild --verbose --flake ${dots-path} test";
  nrbt = "sudo nixos-rebuild --verbose --flake ${dots-path} boot";

  nrbf = "${nrb} --fast";
  nrsf = "${nrs} --fast";
  nrtf = "${nrt} --fast";
  nrbtf = "${nrbt} --fast";

  dots = "cd ${dots-path}";

  z = "zathura";

  n = "nvim";
  ni = "neovide";

  img = "nsxiv -a";
  im = img;

  mkdir = "mkdir -p";
  hexdump = "hexdump -C";

  ns = "nix-shell --command $SHELL -p";
  py = "nix-shell -p python3 --command python";
}
