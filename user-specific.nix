args@{ config, pkgs, ... }:

{
  imports = [ (import ./create-users.nix (args // { usernames = [ "user" ]; })) ];

  time.timeZone = "America/Sao_Paulo";

  networking.hostName = "nixos";
}
