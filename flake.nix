{
  description = "My NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    hyprshot = {
      url = "github:mateusauler/hyprshot-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    satisfactory-mod-manager = {
      url = "https://github.com/satisfactorymodding/SatisfactoryModManager/releases/download/v2.9.3/Satisfactory-Mod-Manager.AppImage";
      flake = false;
    };

    # A very hacky way to get the icon for SMM
    satisfactory-mod-manager-icon = {
      url = "https://raw.githubusercontent.com/satisfactorymodding/SatisfactoryModManager/b346711bb9c9ee27c235c2b425b588f3e8996b90/icons/512x512.png";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      overlays = [
        (final: prev: {
          inherit (inputs.hyprshot.packages.${final.system}) hyprshot;
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
