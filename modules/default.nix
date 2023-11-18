{ config, lib, pkgs, custom, inputs, ... }:

let
  inherit (custom) username;
  inherit (lib) mkDefault;
in
{
  imports = [
    ./barrier.nix
    ./desktop.nix
    ./efi.nix
    ./openssh.nix
    ./virt-manager
    inputs.sops-nix.nixosModules.sops
  ];

  boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

  time.timeZone = mkDefault "America/Sao_Paulo";
  networking.networkmanager.enable = mkDefault true;

  i18n.defaultLocale = mkDefault "en_GB.UTF-8";
  console = {
    font = mkDefault "Lat2-Terminus16";
    keyMap = mkDefault "br-abnt";
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" ];
      auto-allocate-uids = true;
      auto-optimise-store = mkDefault true;
      keep-outputs = mkDefault true;
      keep-derivations = mkDefault true;
      trusted-users = [ "root" username ];
      use-xdg-base-directories = mkDefault true;
      warn-dirty = mkDefault false;
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

  environment.enableAllTerminfo = true;
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

  users = {
    mutableUsers = false;
    users.root = {
      hashedPassword = "!"; # Disable root password login
      shell = pkgs.fish;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = mkDefault true;
  };
}
