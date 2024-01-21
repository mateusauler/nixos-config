{ lib, ... }:

{ hostname, system, inputs, pkgs, specialArgs ? { }, customDefaults ? { }, dir ? ../hosts/${hostname}, ... }:
let
  inherit (inputs) home-manager nixpkgs;

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

  specialArgs = specialArgs' // { inherit (pkgs) lib; };

  modules = [
    (dir + /configuration.nix)
    ../modules
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        users = lib.mapAttrs (_: _: import (dir + /home.nix)) lib.getUsers;
        useGlobalPkgs = true;
        useUserPackages = false;
        extraSpecialArgs = specialArgs';
        verbose = true;
        sharedModules = [ ../home-manager-modules ];
      };
    }
    private-config.hosts.${hostname} or { }
  ];
}
