{ lib, ... }:

{ hostname, system, inputs, pkgs, specialArgs ? { }, customDefaults ? { }, ... }:
let
  inherit (inputs) home-manager nixpkgs;

  dir = ../hosts + "/${hostname}";
  custom = customDefaults
    // import (dir + /custom.nix)
    // { inherit hostname; };
  username = custom.username;
  specialArgs' = specialArgs // { inherit inputs custom; };
  base = nixpkgs.lib.nixosSystem rec {
    # TODO: Look into replacing system with localSystem
    #       Suggested here: https://discordapp.com/channels/568306982717751326/741347063077535874/1140546315990859816
    inherit system pkgs;

    specialArgs = specialArgs';

    modules = [
      (dir + /configuration.nix)
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          users = lib.mapAttrs (_: _: import (dir + /home.nix)) lib.getUsers;
          useGlobalPkgs = true;
          useUserPackages = false;
          extraSpecialArgs = specialArgs;
        };
      }
    ];
  };
in
base.extendModules {
  modules = [ (import inputs.private-config { inherit lib pkgs; }) ];
  specialArgs = { prev = base; };
}
