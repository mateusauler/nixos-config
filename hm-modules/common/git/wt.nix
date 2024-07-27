{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.git;
in
lib.mkIf cfg.wt {
  home.packages = [ pkgs.git-worktree-switcher ];

  programs = {
    fish.shellInit = "command wt init fish | source";
    bash.initExtra = ''eval "$(command wt init bash)"'';
  };
}
