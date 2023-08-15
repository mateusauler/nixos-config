{ lib, ... }:

{
  readDirNames = path:
    builtins.attrNames
      (lib.filterAttrs
        (_: type: type == "directory")
        (builtins.readDir path)
      );

  mkNixosSystem = { hostname, system, inputs, pkgs, specialArgs ? { }, ... }:
    let
      inherit (inputs) home-manager nixpkgs;

      dir = ../hosts + "/${hostname}";
      custom = (import (dir + /custom.nix)) // { inherit hostname; };
      username = custom.username;
      intermediary = specialArgs // { inherit inputs custom; };
    in
      let
        specialArgs = intermediary;
      in nixpkgs.lib.nixosSystem {
        # TODO: Look into replacing system with localSystem
        #       Suggested here: https://discordapp.com/channels/568306982717751326/741347063077535874/1140546315990859816
        inherit system pkgs specialArgs;

        modules = [
          (dir + /configuration.nix)
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.${username} = import (dir + /home.nix);
              useGlobalPkgs = true;
              useUserPackages = false;
              extraSpecialArgs = specialArgs;
            };
          }
        ];
      };
}
