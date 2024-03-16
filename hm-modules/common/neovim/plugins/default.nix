{ config, lib, pkgs, ... }:

let
  cfg = config.modules.neovim;
in
{
  imports = [
    ./cmp.nix
    ./lsp.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      # Hacky way of creating a "global" luasnip variable
      extraConfigLuaPre = lib.optionalString config.programs.nixvim.plugins.luasnip.enable /* lua */ "local luasnip = require('luasnip')";

      extraPackages = with pkgs; [
        fd
        mercurial
      ];

      plugins = {
        auto-session.enable = true;
        bufferline.enable = true;
        comment-nvim.enable = true;
        diffview.enable = true;
        gitsigns.enable = true;
        lualine.enable = true;
        luasnip.enable = true;
        neo-tree.enable = true;
        nix.enable = true;
        nvim-colorizer.enable = true;
        nvim-autopairs.enable = true;
        rainbow-delimiters.enable = true;
        # FIXME: Should be rustaceanvim, but it's not available in nixvim stable
        rust-tools = {
          enable = true;
          server = {
            check.command = "clippy";
            typing.autoClosingAngleBrackets.enable = true;
          };
        };
        surround.enable = true;
        telescope = {
          enable = true;
          keymaps = {
            "<leader>ff" = { action = "find_files"; desc = "Telescope: Find files"; };
            "<leader>fg" = { action = "live_grep";  desc = "Telescope: Live grep"; };
            "<leader>fb" = { action = "buffers";    desc = "Telescope: Buffers"; };
            "<leader>fh" = { action = "help_tags";  desc = "Telescope: Help tags"; };
          };
        };
        todo-comments.enable = true;
        treesitter = {
          enable = true;
          indent = true;
          nixvimInjections = true;
        };
        which-key.enable = true;
      };

      extraPlugins = with pkgs.vimPlugins; [
        vim-numbertoggle
        neodev-nvim
      ];
    };
  };
}
