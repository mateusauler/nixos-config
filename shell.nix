{ pkgs ? # If pkgs is not defined, instanciate nixpkgs from locked commit
  let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
  import nixpkgs { overlays = [ ]; }
, ...
}: {
  default = pkgs.mkShell {
    name = "nix bootstrap";
    NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";
    shellHook = "exec $SHELL";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git

      sops
      ssh-to-age
      gnupg
      age
    ];
  };
}