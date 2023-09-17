{
  description = "My NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    hyprland.url = "github:hyprwm/Hyprland";

    hyprshot = {
      url = "github:mateusauler/hyprshot-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";

    overlays = [
      (final: prev: {
        inherit (inputs.hyprland.packages."${final.system}") hyprland;
        inherit (inputs.hyprshot.packages."${final.system}") hyprshot;
        lib = prev.lib // import ./lib { inherit (final) lib; inherit pkgs; };
      })
    ];

    pkgs = import nixpkgs {
      inherit overlays;
      localSystem = system;
      config.allowUnfree = true;
    };

    # Default values of the custom set
    customDefaults = {
      dots-path = "~/nixos";
      color-scheme = "gruvbox-dark-medium";
      keyboard-layout = "br";
    };

    machines = lib.readDirNames ./hosts;

    specialArgs = { inherit (inputs) nix-colors; };

    mkHost = accumulator: hostname:
      accumulator // {
        ${hostname} =
          lib.mkNixosSystem { inherit hostname system inputs pkgs customDefaults specialArgs; };
      };

    inherit (pkgs) lib;
  in
    { nixosConfigurations = lib.foldl mkHost { } machines; };
}
