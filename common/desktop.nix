{ pkgs, custom, config, lib, ... }:

let
  inherit (custom) username;
  inherit (lib) mkDefault;
  cfg = config.modules.desktop;
in {
  options.modules.desktop.enable = lib.mkEnableOption "desktop";

  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable =  true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    sound.enable = true;

    services = {
      pipewire = {
        enable = mkDefault true;
        alsa = {
          enable = mkDefault true;
          support32Bit = mkDefault true;
        };
        pulse.enable = mkDefault true;
        jack.enable = mkDefault true;
      };

      udisks2 = {
        enable = mkDefault true;
        mountOnMedia = mkDefault true;
      };

      syncthing = {
        enable = mkDefault true;
        openDefaultPorts = mkDefault true;
        user = mkDefault "${username}";
        dataDir = mkDefault "/home/${username}/Sync";
        configDir = mkDefault "/home/${username}/.config/syncthing";
      };

      mullvad-vpn = {
        enable = mkDefault true;
        package = mkDefault pkgs.mullvad-vpn;
      };
    };

    programs.direnv.enable = mkDefault true;

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
  };
}