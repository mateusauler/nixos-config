{ lib, ... }:

{ hostname, system, inputs, pkgs, specialArgs ? { }, customDefaults ? { }, ... }:
let
  inherit (inputs) home-manager nixpkgs;

  dir = ../hosts + "/${hostname}";
  custom = customDefaults
    // import (dir + /custom.nix)
    // { inherit hostname; };
  specialArgs' = specialArgs // { inherit inputs custom; };

  private-config = import inputs.private-config (inputs // { inherit lib pkgs; });
in
nixpkgs.lib.nixosSystem rec {
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
    private-config.hosts.${hostname} or { }
  ];
}
