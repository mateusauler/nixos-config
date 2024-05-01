{ config, inputs, lib, pkgs, ... }:

let
  cfg = config.modules.git;

  package = pkgs.stdenv.mkDerivation {
    name = "wt";

    src = inputs.git-worktree-switcher;

    nativeBuildInputs = [ pkgs.installShellFiles ];

    patches = [
      ./remove_update_functionality.diff
      # https://github.com/yankeexe/git-worktree-switcher/pull/15
      ./cd_no_new_shell.diff
      # https://github.com/yankeexe/git-worktree-switcher/pull/16
      ./fix_completions.diff
    ];

    installPhase = /* bash */ ''
      mkdir -p $out/bin
      cp wt $out/bin/wt
      installShellCompletion --cmd wt \
        --bash completions/wt_completion \
        --fish completions/wt.fish \
        --zsh completions/_wt_completion
    '';
  };
in
lib.mkIf cfg.wt {
  home.packages = [ package ];
  programs = {
    fish.shellInit = /* fish */ "command wt init fish | source";
    bash.initExtra = /* bash */ ''eval "$(command wt init bash)"'';
  };
}
