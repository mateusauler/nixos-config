{
  description = "My NixOS config";

  inputs = rec {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs = nixpkgs-stable;

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.11";
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

    nixvim-stable = {
      url = "github:nix-community/nixvim/nixos-23.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nixvim-unstable = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    nix-colors.url = "github:Misterio77/nix-colors";

    gx = {
      url = "github:chrishrb/gx.nvim";
      flake = false;
    };

    git-worktree-switcher = {
      url = "github:yankeexe/git-worktree-switcher";
      flake = false;
    };

    satisfactory-mod-manager = {
      url = "https://github.com/satisfactorymodding/SatisfactoryModManager/releases/latest/download/Satisfactory-Mod-Manager.AppImage";
      flake = false;
    };
  };

  outputs = inputs@{ nix-colors, nixpkgs-stable, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      default-channel = "unstable";

      overlays = [
        (final: prev: {
          lib = prev.lib // import ./lib { inherit (final) lib; inherit pkgs; };
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

      specialArgs = { inherit nix-colors nixpkgs-stable nixpkgs-unstable pkgs-stable pkgs-unstable lib-stable lib-unstable; };

      mkHost = acc: hostname:
        acc // {
          ${hostname} =
            lib-stable.mkNixosSystem { inherit hostname system inputs default-channel pkgs specialArgs private-config hosts-preferred-nixpkgs-channel; };
        };
    in
    {
      nixosConfigurations = (private-config.systems { inherit system inputs default-channel pkgs specialArgs; }) // (lib.foldl mkHost { } machines);
      devShells.${system}.default = import ./shell.nix { inherit pkgs; };
      templates = import ./templates;
    };
}
