args@{ config, pkgs, ... }:

{
  imports = [ (import ./create-users.nix (args // { username = "user"; })) ];

  time.timeZone = "America/Sao_Paulo";

  networking.hostName = "nixos";
}
