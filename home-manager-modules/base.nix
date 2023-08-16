{ inputs, custom, config, lib, pkgs, ... }:

{
  imports = [ ./. ];

  programs.home-manager.enable = true;

  home =
  let
    inherit (custom) username;
  in
  {
    inherit username;
    homeDirectory = "/home/${username}";
  };
}