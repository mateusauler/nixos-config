{ config, pkgs, custom, ... }:

let username = custom.username;
in {
  imports = [ ./hyprland.nix ];

  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";

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

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" ];
    auto-allocate-uids = true;
    auto-optimise-store = true;
    trusted-users = [ "root" username ];
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
    exa
    ferdium
    firefox
    firejail
    git
    heroic
    home-manager
    htop-vim
    keepassxc
    librewolf
    megasync
    meld
    mpv
    neovide
    nodejs
    nsxiv
    onlyoffice-bin
    pcmanfm
    pfetch
    qbittorrent
    qogir-icon-theme
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

  programs.fish.enable = true;

  users.defaultUserShell = pkgs.fish;

  services.syncthing = {
    user = "${username}";
    dataDir = "/home/${username}/Sync";
    configDir = "/home/${username}/.config/syncthing";
  };

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