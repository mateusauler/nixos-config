{ pkgs, ... }:

let
  module-names = [ "server" ];
in
{
  modules = pkgs.lib.enableModules module-names;

  home.stateVersion = "23.11";
}
