{ config, inputs, lib, pkgs, ... }:

let
  cfg = config.modules.git;
  package = pkgs.stdenv.mkDerivation {
    name = "wt";

    src = inputs.git-worktree-switcher;

    patches = [
      ./remove_update_functionality.diff
    ];

    installPhase = /* bash */ ''
      mkdir -p $out/bin
      cp wt $out/bin/wt
    '';
  };
in
lib.mkIf cfg.wt {
  home.packages = [ package ];
}
