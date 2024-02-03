{ pkgs, custom, config, lib, ... }:

let
  inherit (custom) username;
  inherit (lib) mkDefault;
  cfg = config.modules.desktop;
  module-names = [ "barrier" "distrobox" "localsend" "wally" ];
in
{
  options.modules.desktop.enable = lib.mkEnableOption "desktop";

  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      config = {
        common.default = [ "gtk" ];
        hyprland.default = [ "gtk" "hyprland" ];
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
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

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    modules = lib.enableModules module-names;

    fonts = with custom;{
      enableDefaultPackages = true;
      packages = with pkgs; [
        font-awesome
        liberation_ttf
        nerdfonts
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        font-sans.package
        font-serif.package
        font-mono.package
      ];
      fontconfig.defaultFonts = {
        sansSerif = [ font-sans.name ];
        serif = [ font-serif.name ];
        monospace = [ font-mono.name ];
      };
    };

    environment.systemPackages = with pkgs; [
      firejail
      nodejs
    ];
  };
}
