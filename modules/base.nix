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
      keep-outputs = mkDefault true;
      keep-derivations = mkDefault true;
      trusted-users = [ "root" username ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  # Enable running appimages as executables, by setting appimage-run as the interpreter
  # https://nixos.wiki/wiki/Appimage
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  environment.systemPackages = with pkgs; [
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
