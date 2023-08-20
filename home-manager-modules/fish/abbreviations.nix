{ custom }:

let
  inherit (custom) dots-path;
in {
  mn  =   "udisksctl mount -b";
  um  =   "udisksctl umount -b";

  g   =   "git";

  gs  =  "git status";
  gu  =  "git push";
  gl  =  "git pull";
  ga  =  "git add";
  gap =  "git add -p";
  gc  =  "git commit";
  gca =  "git commit --amend";
  gh  =  "git checkout";
  gb  =  "git branch";
  gd  =  "git diff";
  gdc =  "git diff --cached";
  gg  =  "git grep";
  ggi =  "git grep -i";

  nrb = "nixos-rebuild --flake ${dots-path} --show-trace build";
  nrs = "sudo nixos-rebuild --flake ${dots-path} switch";
  nrt = "sudo nixos-rebuild --flake ${dots-path} test";

  pa  =  "patch -p1 <";

  # p  =  "paru";
  z   =  "zathura";

  n   =  "nvim";
  ni  =  "neovide";

  ns  =  "nsxiv -a";

  mkdir = "mkdir -p";
  hexdump = "hexdump -C";

  py = "nix-shell -p python3 --command python";
}
