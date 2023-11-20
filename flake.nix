{
  description = "My NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: Revert to the original repo, once https://github.com/Misterio77/nix-colors/pull/39 is merged.
    nix-colors.url = "github:mateusauler/nix-colors/textmate-theme";

    hyprshot = {
      url = "github:mateusauler/hyprshot-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ hyprshot, nix-colors, nixpkgs, ... }:
    let
      system = "x86_64-linux";

      overlays = [
        (final: prev: {
          inherit (hyprshot.packages.${final.system}) hyprshot;
          lib = prev.lib // import ./lib { inherit (final) lib; inherit pkgs; };
        })
      ];

      pkgs = import nixpkgs {
        inherit overlays;
        localSystem = system;
        config.allowUnfree = true;
      };

      # Default values of the custom set
      customDefaults = rec {
        dots-path = "~/nixos";
        color-scheme = "catppuccin-mocha";
        keyboard-layout = "br";
        font-sans = {
          package = pkgs.roboto;
          name = "Roboto";
          size = 12;
        };
        font-serif = font-sans;
        font-mono = {
          package = pkgs.nerdfonts;
          name = "FiraCode Nerd Font Mono";
          size = 12;
        };
      };

      machines = lib.readDirNames ./hosts;

      specialArgs = { inherit nix-colors; };

      mkHost = accumulator: hostname:
        accumulator // {
          ${hostname} =
            lib.mkNixosSystem { inherit hostname system inputs pkgs customDefaults specialArgs; };
        };

      inherit (pkgs) lib;
    in
    {
      nixosConfigurations = lib.foldl mkHost { } machines;
      devShells.${system} = import ./shell.nix { inherit pkgs; };
    };
}
