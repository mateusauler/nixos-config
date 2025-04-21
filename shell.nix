{
  pkgs ? # If pkgs is not defined, instanciate nixpkgs from locked commit
    let
      lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs-stable.locked;
      nixpkgs = fetchTarball {
        url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
        sha256 = lock.narHash;
      };
    in
    import nixpkgs { overlays = [ ]; },
  ...
}:

pkgs.mkShell {
  name = "nix bootstrap";
  nativeBuildInputs = with pkgs; [
    nix
    home-manager
    git
    jujutsu

    sops
    ssh-to-age
    gnupg
    age
  ];
}
