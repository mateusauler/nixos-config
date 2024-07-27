{
  installShellFiles,
  src,
  stdenv,
}:

stdenv.mkDerivation {
  name = "wt";

  inherit src;

  nativeBuildInputs = [ installShellFiles ];

  patches = [ ./remove_update_functionality.diff ];

  installPhase = # bash
    ''
      mkdir -p $out/bin
      cp wt $out/bin/wt
      installShellCompletion --cmd wt \
        --bash completions/wt_completion \
        --fish completions/wt.fish \
        --zsh completions/_wt_completion
    '';
}
