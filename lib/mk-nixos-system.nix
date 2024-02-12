{ lib, ... }:

{ hostname
, system
, inputs
, default-channel
, specialArgs ? { }
, dir ? ../hosts/${hostname}
, private-config ? import inputs.private-config (inputs // { inherit lib; inherit (args) pkgs; })
, hosts-preferred-nixpkgs-channel ? { }
, ...
}@args:

assert lib.assertOneOf "default-channel" default-channel [ "stable" "unstable" ];

let
  nixpkgs-channel = hosts-preferred-nixpkgs-channel.${hostname} or default-channel;

  get-variable = base-name: origin:
    assert lib.assertOneOf "nixpkgs channel for ${hostname}" nixpkgs-channel [ "stable" "unstable" ];
    origin."${base-name}-${nixpkgs-channel}";

  nixpkgs = get-variable "nixpkgs" inputs;
  pkgs = get-variable "pkgs" specialArgs;
  home-manager = get-variable "home-manager" inputs;

  specialArgs' = specialArgs // { inherit inputs private-config default-channel nixpkgs-channel; };

  configPath = dir + /configuration.nix;
  inherit (import configPath (args // { inherit (pkgs) lib; })) enabledUsers;
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
