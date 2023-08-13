{
  description = "My NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hyprshot.url = "github:mateusauler/hyprshot-nix";
    hyprshot.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
  let
    system = "x86_64-linux";

    overlays = [
      (final: prev: {
        lib = prev.lib // { my = import ./lib { inherit (final) lib; }; };
      })
    ];

    pkgs = import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };

    flakePkgs = {
      inherit (inputs.hyprshot.packages."${system}") hyprshot;
    };

    inherit (pkgs) lib;
  in
  {
    nixosConfigurations =
    let
      machines = lib.my.readDirNames ./hosts;

      makeASystem = accumulator: hostname:
        accumulator // {
          ${hostname} = 
            lib.my.mkNixosSystem {
              inherit hostname system inputs pkgs;
              specialArgs = { inherit flakePkgs; };
            };
        };
    in
      builtins.foldl' makeASystem { } machines;
  };
}
