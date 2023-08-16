{ lib, pkgs, custom, ... }:

let
  inherit (custom) username;
  inherit (lib) mkDefault;
in {
  time.timeZone = mkDefault "America/Sao_Paulo";
  networking.networkmanager.enable = mkDefault true;

  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    XDG_BIN_HOME    = "$HOME/.local/bin";
    PATH = [ "${XDG_BIN_HOME}" ];
  };

  nixpkgs.config.allowUnfree = mkDefault true;
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" ];
      auto-allocate-uids = true;
      auto-optimise-store = true;
      trusted-users = [ "root" username ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 1w";
    };
  };

  environment.systemPackages = with pkgs; [
    bat
    btop
    dconf
    du-dust
    exa
    git
    htop-vim
    meld
    pfetch
    ripgrep
    tldr
    tree
    wget
  ];

  programs.fish.enable = true;

  users.defaultUserShell = pkgs.fish;

  users.users = {
    ${username} = {
      isNormalUser = true;
      group = "users";
      extraGroups = [ "wheel" "input" "networkmanager" ];
      initialPassword = "a";
      createHome = true;
      home = "/home/${username}";
    };
    root.initialPassword = "a";
  };
}
