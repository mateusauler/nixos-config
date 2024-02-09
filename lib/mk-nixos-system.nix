{ lib, ... }:

{ hostname
, system
, inputs
, specialArgs ? { }
, dir ? ../hosts/${hostname}
, private-config ? import inputs.private-config (inputs // { inherit lib; inherit (args) pkgs; })
, hosts-preferred-nixpkgs-branch ? { }
, ...
}@args:
let
  nixpkgs-branch = hosts-preferred-nixpkgs-branch.${hostname} or null;

  get-variable = base-name: def: alt-origin:
    if nixpkgs-branch == null then
      def
    else if nixpkgs-branch == "stable" || nixpkgs-branch == "unstable" then
      alt-origin."${base-name}-${nixpkgs-branch}"
    else
      throw "Unknown nixpkgs branch: ${nixpkgs-branch}";

  nixpkgs = get-variable "nixpkgs" inputs.nixpkgs inputs;
  pkgs = get-variable "pkgs" args.pkgs specialArgs;
  home-manager = get-variable "home-manager" inputs.home-manager inputs;

  specialArgs' = specialArgs // { inherit inputs; };

  configPath = dir + /configuration.nix;
  inherit (import configPath { inherit (pkgs) lib; }) enabledUsers;
in
nixpkgs.lib.nixosSystem rec {
  # TODO: Look into replacing system with localSystem
  #       Suggested here: https://discordapp.com/channels/568306982717751326/741347063077535874/1140546315990859816
  inherit system pkgs;

  specialArgs = specialArgs' // { inherit (pkgs) lib; };

  modules = [
    configPath
    ../modules
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        users = lib.foldl (acc: u: acc // { ${u} = import (dir + /home.nix); }) { } enabledUsers;
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
