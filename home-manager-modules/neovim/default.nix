{ config, custom, lib, nix-colors, pkgs, ... }:

let
  cfg = config.modules.neovim;
  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
in {
  options.modules.neovim.enable = lib.mkEnableOption "neovim";

  imports = [
    ./plugins
  ];

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      defaultEditor = true;
      extraConfig = builtins.readFile ./config.vim;
      plugins = [{
        plugin = nix-colors-lib.vimThemeFromScheme { scheme = config.colorScheme; };
        config = "colorscheme nix-${config.colorScheme.slug}";
      }];
    };

    # Re-source the config on running nvim instances
    home.activation.source-nvim-init = lib.hm.dag.entryAfter ["writeBoundary"] ''
      XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
      for server in $XDG_RUNTIME_DIR/nvim.*; do
        $DRY_RUN_CMD ${pkgs.neovim}/bin/nvim --server $server --remote-send ':source ${config.xdg.configHome}/nvim/init.lua<CR>' &
      done
    '';
  };
}
