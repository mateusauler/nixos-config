{
  description = "My NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
        lib = prev.lib // { my = import ./lib { inherit (final) lib; inherit pkgs; }; };
      })
    ];

    flakePkgs = {
      inherit (inputs.hyprshot.packages."${system}") hyprshot;
    };

    pkgs = import nixpkgs {
      inherit overlays;
      localSystem = system;
      config.allowUnfree = true;
    } // flakePkgs;

    # Default values of the custom set
    customDefaults = {
      dots-path = "~/nixos";
      default-wallpaper = "nix-wallpaper-dracula.png";
    };

    machines = lib.my.readDirNames ./hosts;

    mkHost = accumulator: hostname:
      accumulator // {
        ${hostname} =
          lib.my.mkNixosSystem { inherit hostname system inputs pkgs customDefaults; };
      };

    inherit (pkgs) lib;
  in
    { nixosConfigurations = lib.foldl mkHost { } machines; };
}
