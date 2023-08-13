args@{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./hyprland.nix ./user-specific.nix (import ./create-users.nix (args // { username = "mateus"; })) ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  networking.networkmanager.enable = true;

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

    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };

    syncthing = {
      enable = true;
      openDefaultPorts = true;
    };

    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
  };

  time.timeZone = "America/Sao_Paulo";

  nixpkgs.config.allowUnfree = true;
  system = {
    autoUpgrade.enable = true;
    copySystemConfiguration = true;
  };
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" ];
    auto-allocate-uids = true;
    auto-optimise-store = true;
  };

  # ssh
  services.openssh.enable = true;
  security.rtkit.enable = true;
  networking.firewall = {
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 22 ];
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
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

    direnv.enable = true; # VSCodium Nix extension
    steam.enable = true;
  };

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
    brave
    btop
    du-dust
    easyeffects
    efibootmgr
    exa
    ferdium
    firefox
    firejail
    git
    heroic
    htop-vim
    keepassxc
    librewolf
    lutris
    megasync
    meld
    mpv
    neovide
    nodejs
    nsxiv
    onlyoffice-bin
    pcmanfm
    pfetch
    prismlauncher
    qbittorrent
    qogir-icon-theme
    refind
    ripgrep
    spotify
    syncthing-tray
    tldr
    tree
    ungoogled-chromium
    vscodium
    wget
    yt-dlp
    zathura
  ];

  system.stateVersion = "22.11";
}

