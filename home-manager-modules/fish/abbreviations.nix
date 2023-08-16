{
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

  # TODO: Use a variable to refer to the path of the repo
  nrb = "nixos-rebuild --flake ~/nixos --show-trace build";
  nrs = "sudo nixos-rebuild --flake ~/nixos switch";
  nrt = "sudo nixos-rebuild --flake ~/nixos test";

  pa  =  "patch -p1 <";

  # p  =  "paru";
  z   =  "zathura";

  vim =  "nvim";
  n   =  "nvim";
  ni  =  "neovide";

  ns  =  "nsxiv -a";

  hexdump = "hexdump -C";
}