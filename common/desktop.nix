{ config, pkgs, custom, ... }:

let username = custom.username;
in {
  imports = [ ./hyprland.nix ./base.nix ];

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
    brave
    easyeffects
    ferdium
    firefox
    firejail
    keepassxc
    librewolf
    megasync
    mpv
    neovide
    nodejs
    nsxiv
    onlyoffice-bin
    pcmanfm
    qbittorrent
    qogir-icon-theme
    spotify
    syncthing-tray
    ungoogled-chromium
    vscodium
    yt-dlp
    zathura
  ];

  services.syncthing = {
    user = "${username}";
    dataDir = "/home/${username}/Sync";
    configDir = "/home/${username}/.config/syncthing";
  };
}