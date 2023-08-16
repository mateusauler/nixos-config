{ pkgs, custom, ... }:

let
  inherit (custom) username;
in {
  imports = [ ./base.nix ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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
      user = "${username}";
      dataDir = "/home/${username}/Sync";
      configDir = "/home/${username}/.config/syncthing";
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

    direnv.enable = true;
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
    at-spi2-core
    brave
    easyeffects
    ferdium
    firefox
    firejail
    keepassxc
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
}