{ inputs, custom, config, lib, pkgs, ... }:

let
  inherit (lib) mkDefault;
in {
  imports = [ ./. ];

  programs.home-manager.enable = true;

  modules = {
    fish.enable = mkDefault true;
  };

  xdg = {
    enable = mkDefault true;
    userDirs = {
      enable = mkDefault true;
      desktop   = mkDefault null;
      documents = mkDefault "${config.home.homeDirectory}/docs";
      download  = mkDefault "${config.home.homeDirectory}/dl";
      music     = mkDefault "${config.home.homeDirectory}/music";
      pictures  = mkDefault "${config.home.homeDirectory}/pics";
      videos    = mkDefault "${config.home.homeDirectory}/vids";
    };
  };

  home =
  let
    inherit (custom) username;
  in
  {
    inherit username;
    homeDirectory = "/home/${username}";

    packages = with pkgs; [
      btop
      du-dust
      htop-vim
      meld
      tldr
      wget
    ];
  };
}