{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./hyprland.nix ./user-specific.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking = {
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    firewall = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 22 ];
    };
  };

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt";
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    XDG_BIN_HOME    = "$HOME/.local/bin";
    PATH = [ "${XDG_BIN_HOME}" ];
  };

  sound.enable = true;
  security.rtkit.enable = true;

  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    openssh.enable = true;

    syncthing = {
      enable = true;
      openDefaultPorts = true;
    };
  };

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      configure = {
         customRC = ''
           set number
           set relativenumber
           if &diff
             colorscheme blue
           endif
         '';
         packages.all.start = with pkgs.vimPlugins; [
           nvim-treesitter.withAllGrammars
         ];
      };
    };

    steam.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  #services.xserver.libinput.enable = true;

  system.autoUpgrade.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      font-awesome
      nerdfonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
    ];
  };

  environment.systemPackages = with pkgs; [
    bat
    btop
    du-dust
    easyeffects
    efibootmgr
    exa
    ferdium
    firejail
    git
    htop-vim
    keepassxc
    librewolf
    megasync
    meld
    mpv
    neovide
    nsxiv
    pcmanfm
    pfetch
    prismlauncher
    refind
    ripgrep
    spotify
    syncthing-tray
    tldr
    tree
    vscodium
    wget
    yt-dlp
    zathura
  ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  system.stateVersion = "22.11";
}

