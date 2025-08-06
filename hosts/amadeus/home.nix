{ pkgs, ... }:

let
  module-names = [ ];
in
{
  modules = pkgs.lib.enableModules module-names { };

  home.stateVersion = "23.11";
}
