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

  programs.direnv.enable = true;

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
    firejail
    nodejs
  ];
}