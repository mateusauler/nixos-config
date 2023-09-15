{ config, custom, lib, pkgs, ... }:

let
  cfg = config.modules.neovim;
  inherit (custom) dots-path;
in {
  config = lib.mkIf cfg.enable {
    programs.neovim.plugins = with pkgs.vimPlugins; [
      vim-nix
      nvim-treesitter.withAllGrammars

      vim-illuminate
      vim-numbertoggle

      {
        plugin = alpha-nvim;
        type = "lua";
        config = "local dotspath = '${dots-path}'" + (builtins.readFile ./alpha-nvim.lua);
      }
      {
        plugin = bufferline-nvim;
        type = "lua";
        config = /* lua */ ''
          require('bufferline').setup{}
        '';
      }
      {
        plugin = nvim-web-devicons;
        type = "lua";
        config = /* lua */ ''
          require('nvim-web-devicons').setup{}
        '';
      }
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require("lualine").setup({
            icons_enabled = true,
          })
        '';
      }
    ];
  };
}