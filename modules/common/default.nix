{ ... }:

{
  imports = [
    ./appimage.nix
    ./deploy-secrets
    ./efi.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./zswap.nix
  ];
}
