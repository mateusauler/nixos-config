{ lib, pkgs, custom, ... }:

let
  inherit (custom) username;
  inherit (lib) mkDefault;
in {
  boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

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
      auto-optimise-store = mkDefault true;
      trusted-users = [ "root" username ];
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };

  environment.systemPackages = with pkgs; [
    bat
    dconf
    file
    ripgrep
    tree
    unzip
    zip
  ];

  # TODO: Handle this in home-manager
  programs.fish.enable = true;

  users.defaultUserShell = pkgs.fish;

  users.users = {
    ${username} = {
      isNormalUser = true;
      group = "users";
      extraGroups = [ "wheel" "input" "networkmanager" "disk" ];
      initialPassword = "a";
      createHome = true;
      home = "/home/${username}";
    };
    root.hashedPassword = "!";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = mkDefault true;
  };
}
