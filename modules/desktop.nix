{ pkgs, custom, config, lib, ... }:

let
  inherit (custom) username;
  inherit (lib) mkDefault;
  cfg = config.modules.desktop;
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

    modules.barrier.enable = mkDefault true;

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
        serif     = [ font-serif.name ];
        monospace = [ font-mono.name ];
      };
    };

    environment.systemPackages = with pkgs; [
      firejail
      nodejs
    ];

    # TODO: Move to docker/distrobox module
    virtualisation.docker = {
      enable = true;
      rootless.enable = true;
    };
    # Enable rootless docker access
    users.users.${username}.extraGroups = [ "docker" ];
  };
}
