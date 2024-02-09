{ config, inputs, lib, osConfig, pkgs, nix-colors, ... }@args:

let
  inherit (lib) mkDefault;
  module-names = [ "bat" "fish" "neovim" "wget" "xdg" "xdg.compliance" ];
in
{
  options.dots-path = lib.mkOption { default = "~/nixos"; };

  imports = [
    nix-colors.homeManagerModules.default
    ./bash.nix
    ./bat.nix
    ./common
    ./copyq
    ./direnv.nix
    ./ferdium.nix
    ./fish
    ./git.nix
    ./gtk.nix
    ./hyprland
    ./kitty
    ./librewolf
    ./libvirtd.nix
    ./mako.nix
    ./mega.nix
    ./meld.nix
    ./mpv.nix
    ./neovim
    ./nsxiv.nix
    ./obs.nix
    ./qt.nix
    ./rofi
    ./scripts
    ./smm.nix
    ./swaylock.nix
    ./waybar
    ./wget.nix
    ./wofi.nix
    ./xdg
    ./xresources.nix
  ];

  config = {
    colorScheme = mkDefault nix-colors.colorSchemes."catppuccin-mocha";

    programs.home-manager.enable = true;

    modules = pkgs.lib.enableModules module-names;

    home = {
      sessionVariables = {
        TERMINAL = "$TERM";
        COLORTERM = "$TERM";
        VISUAL = "$EDITOR";
      };

      packages = with pkgs; [
        btop
        du-dust
        htop-vim
        python3
        tldr
      ];

      activation.clone-dots = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        pkgs.lib.cloneRepo {
          path = config.dots-path;
          url = "https://github.com/mateusauler/nixos-config";
          ssh-uri = "git@github.com:mateusauler/nixos-config.git";
        }
      );
    };

    # Use the same nix settings in home-manager as in the full system config
    # This is useful if using standalone home-manager
    nix.settings = osConfig.nix.settings;
  };
}
