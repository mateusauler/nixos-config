{
  description = "My NixOS config";

  inputs = rec {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs = nixpkgs-unstable;
    home-manager = home-manager-unstable;

    private-config = {
      # url = "path:/home/mateus/repos/nixos-private-config";
      url = "git+ssh://git@github.com/mateusauler/nixos-private-config";
      flake = false;
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    # TODO: Revert to the original repo, once https://github.com/Misterio77/nix-colors/pull/39 is merged.
    nix-colors.url = "github:mateusauler/nix-colors/textmate-theme";

    hyprshot = {
      url = "github:mateusauler/hyprshot-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    satisfactory-mod-manager = {
      url = "https://github.com/satisfactorymodding/SatisfactoryModManager/releases/latest/download/Satisfactory-Mod-Manager.AppImage";
      flake = false;
    };
  };

  outputs = inputs@{ hyprshot, nix-colors, nixpkgs, nixpkgs-stable, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";

      overlays = [
        (final: prev: {
          inherit (hyprshot.packages.${final.system}) hyprshot;
          lib = prev.lib // import ./lib { inherit (final) lib; inherit pkgs; };
        })
      ];

      pkgs-args = {
        inherit overlays;
        localSystem = system;
        config.allowUnfree = true;
      };

      pkgs = import nixpkgs pkgs-args;
      pkgs-stable = import nixpkgs-stable pkgs-args;
      pkgs-unstable = import nixpkgs-unstable pkgs-args;

      inherit (pkgs) lib;
      lib-stable = pkgs-stable.lib;
      lib-unstable = pkgs-unstable.lib;

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

      private-config = import inputs.private-config (inputs // { inherit lib pkgs; });
      machines = lib.readDirNames ./hosts;
      hosts-preferred-nixpkgs-branch = { };

      specialArgs = { inherit nix-colors pkgs-stable pkgs-unstable lib-stable lib-unstable; };

      mkHost = acc: hostname:
        acc // {
          ${hostname} =
            lib-stable.mkNixosSystem { inherit hostname system inputs pkgs customDefaults specialArgs private-config hosts-preferred-nixpkgs-branch; };
        };
    in
    {
      nixosConfigurations = (private-config.systems { inherit system inputs pkgs customDefaults specialArgs; }) // (lib.foldl mkHost { } machines);
      devShells.${system}.default = import ./shell.nix { inherit pkgs; };
    };
}
