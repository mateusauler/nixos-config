{ ... }:

{
  imports = [
    ./appimage.nix
    ./deploy-secrets
    ./docker.nix
    ./efi.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./zswap.nix
  ];
}
