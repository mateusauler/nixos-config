{ lib, pkgs, custom, ... }:

let
  inherit (custom) username;
  inherit (lib) mkDefault;
in {
  time.timeZone = mkDefault "America/Sao_Paulo";
  networking.networkmanager.enable = mkDefault true;

  i18n.defaultLocale = mkDefault "en_GB.UTF-8";
  console = {
    font = mkDefault "Lat2-Terminus16";
    keyMap = mkDefault "br-abnt";
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
    htop-vim
    meld
    ripgrep
    tldr
    tree
    wget
  ];

  # TODO: Handle this in home-manager
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

  hardware.opengl.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = mkDefault true;
  };
}
