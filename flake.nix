{
  description = "My NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprshot.url = "github:mateusauler/hyprshot-nix";
    hyprshot.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";

    overlays = [
      (final: prev: {
        lib = prev.lib // { my = import ./lib { inherit (final) lib; inherit pkgs; }; };
      })
    ];

    pkgs = import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };

    flakePkgs = {
      inherit (inputs.hyprshot.packages."${system}") hyprshot;
    };

    # Default values of the custom set
    customDefaults = {
      dots-path = "~/nixos";
      default-wallpaper = "df74f6793d18725a.png";
    };

    machines = lib.my.readDirNames ./hosts;

    mkHost = accumulator: hostname:
      accumulator // {
        ${hostname} =
          lib.my.mkNixosSystem {
            inherit hostname system inputs pkgs customDefaults;
            specialArgs = { inherit flakePkgs; };
          };
      };

    inherit (pkgs) lib;
  in
    { nixosConfigurations = lib.foldl mkHost { } machines; };
}
