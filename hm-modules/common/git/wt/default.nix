{ config, inputs, lib, pkgs, ... }:

let
  cfg = config.modules.git;

  package = pkgs.stdenv.mkDerivation {
    name = "wt";

    src = inputs.git-worktree-switcher;

    nativeBuildInputs = [ pkgs.installShellFiles ];

    patches = [
      ./remove_update_functionality.diff
      # https://github.com/yankeexe/git-worktree-switcher/pull/14
      ./fail-silent.diff
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
}
