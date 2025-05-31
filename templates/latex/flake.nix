{
  description = "LaTeX";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    with flake-utils.lib;
    eachSystem allSystems (
      system:
      let
        documents = [ "main" ];
        pdfs = map (d: "${d}.pdf") documents;
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combined.scheme-full;
        inherit (pkgs) lib;
      in
      rec {
        devShells.default = pkgs.mkShell {
          inherit (packages.default) name;
          shellHook = # bash
            ''
              chmod +rx .githooks/*
              pre-commit install
            '';
          nativeBuildInputs = lib.flatten [
            pkgs.pre-commit
            packages.document.buildInputs
            packages.document.nativeBuildInputs
          ];
        };

        packages = rec {
          document = pkgs.stdenvNoCC.mkDerivation {
            name = "latex";
            src = self;

            nativeBuildInputs = [ tex ];

            makeFlags = pdfs;

            preBuild = # bash
              ''
                makeFlagsArray+=(-j $(nproc))
                make clean-all
              '';

            preInstall = # bash
              ''
                installFlagsArray+=(INSTALL_DIR="$out")
              '';
          };

          default = document;
        };
      }
    );
}
