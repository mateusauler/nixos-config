{
  callPackage,
  rust-analyzer,
  rustfmt,
  clippy,
  rustPlatform,
}:

let
  mainPkg = callPackage ./default.nix { };
in
mainPkg.overrideAttrs (oa: {
  nativeBuildInputs = [
    # Additional rust tooling
    rust-analyzer
    rustfmt
    clippy
  ] ++ (oa.nativeBuildInputs or [ ]);
  RUST_SRC_PATH = rustPlatform.rustLibSrc;
})
