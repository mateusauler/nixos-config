{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  module-names = [
    "bat"
    "fish"
    "neovim"
    "wget"
    "xdg"
    "xdg.compliance"
  ];
in
{
  options.dots = {
    clone = lib.mkOption { default = true; };
    path = lib.mkOption { default = "~/nixos"; };
    url = lib.mkOption { default = "https://github.com/mateusauler/nixos-config"; };
    ssh-uri = lib.mkOption { default = "git@github.com:mateusauler/nixos-config.git"; };
    nix-uri = lib.mkOption { default = "github:mateusauler/nixos-config"; };
  };

  imports = [
    ./common
    ./desktop
    ./server
  ];

  config = {
    programs.home-manager.enable = true;

    modules = pkgs.lib.enableModules module-names // {
      hyprland.autostart.apply-wallpaper.enable = ! config.stylix.enable;
    };

    programs.zoxide = {
      enable = lib.mkDefault true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      options = [ "--cmd cd" ];
    };

    home = {
      sessionVariables = {
        TERMINAL = "$TERM";
        COLORTERM = "$TERM";
        VISUAL = "$EDITOR";
        # Make less display unicode characters (https://man.archlinux.org/man/less.1.en#NATIONAL_CHARACTER_SETS)
        LESSUTFCHARDEF = "E000-F8FF:p,F0000-FFFFD:p,100000-10FFFD:p";
      };

      packages = with pkgs; [
        du-dust
        htop-vim
        jq
        nix-output-monitor
        progress
        python3
        tlrc
      ];

      activation.clone-dots = lib.optionalString config.dots.clone (
        lib.hm.dag.entryAfter [ "writeBoundary" ] (
          pkgs.lib.cloneRepo { inherit (config.dots) path url ssh-uri; }
        )
      );
    };

    # Use the same nix settings in home-manager as in the full system config
    # This is useful if using standalone home-manager
    nix.settings = osConfig.nix.settings;
  };
}
