{
  description = "My NixOS config";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    private-config = {
      # url = "path:/home/mateus/repos/nixos-private-config";
      url = "git+ssh://git@github.com/mateusauler/nixos-private-config";
      flake = false;
    };

    nixvim-stable.url = "github:nix-community/nixvim/nixos-24.11";

    nixvim-unstable.url = "github:nix-community/nixvim";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    stylix-stable.url = "github:danth/stylix/release-24.11";

    stylix-unstable.url = "github:mateusauler/stylix";

    gx = {
      url = "github:chrishrb/gx.nvim";
      flake = false;
    };

    git-worktree-switcher = {
      url = "github:mateusauler/git-worktree-switcher";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs-stable, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      default-channel = "unstable";

      overlays = [
        (final: prev: {
          lib =
            prev.lib
            // import ./lib {
              inherit (final) lib;
              inherit pkgs;
            };
        })
      ];

      pkgs-args = {
        inherit overlays;
        localSystem = system;
        config.allowUnfree = true;
      };

      pkgs-stable = import nixpkgs-stable pkgs-args;
      pkgs-unstable = import nixpkgs-unstable pkgs-args;
      pkgs = if default-channel == "stable" then pkgs-stable else pkgs-unstable;

      inherit (pkgs) lib;
      lib-stable = pkgs-stable.lib;
      lib-unstable = pkgs-unstable.lib;

      private-config = import inputs.private-config (inputs // { inherit lib pkgs; });
      machines = lib.readDirNames ./hosts;
      hosts-preferred-nixpkgs-channel = {
        amadeus = "stable";
      };

      specialArgs = {
        inherit
          nixpkgs-stable
          nixpkgs-unstable
          pkgs-stable
          pkgs-unstable
          lib-stable
          lib-unstable
          ;
      };

      mkHost =
        acc: hostname:
        acc
        // {
          ${hostname} = lib-stable.mkNixosSystem {
            inherit
              hostname
              system
              inputs
              default-channel
              pkgs
              specialArgs
              private-config
              hosts-preferred-nixpkgs-channel
              ;
          };
        };
    in
    {
      nixosConfigurations =
        (private-config.systems {
          inherit
            system
            inputs
            default-channel
            pkgs
            specialArgs
            ;
        })
        // (lib.foldl mkHost { } machines);
      devShells.${system}.default = import ./shell.nix { inherit pkgs; };
      templates = import ./templates;
    };
}
