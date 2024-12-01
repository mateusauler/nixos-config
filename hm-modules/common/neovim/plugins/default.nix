{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.neovim;
  cfg-plug = config.programs.nixvim.plugins;
in
{
  imports = [
    ./cmp.nix
    ./cursorline.nix
    ./eyeliner.nix
    ./flash.nix
    ./indent-blankline.nix
    ./lsp.nix
    ./neo-tree.nix
    ./oil.nix
    ./telescope.nix
    ./treesitter.nix
    ./trim.nix
    ./ufo.nix
    ./vimtex.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      # Hacky way of creating a "global" luasnip variable
      extraConfigLuaPre = lib.optionalString cfg-plug.luasnip.enable "local luasnip = require('luasnip')";

      extraPackages = with pkgs; [
        cargo
        rustc
      ];

      plugins = {
        auto-session.enable = true;
        bufferline.enable = true;
        comment.enable = true;
        cursorline.enable = true;
        dap.enable = true;
        diffview.enable = true;
        flash.enable = true;
        friendly-snippets.enable = true;
        gitsigns.enable = true;
        illuminate.enable = true;
        indent-blankline.enable = true;
        lsp.enable = true;
        lualine.enable = true;
        luasnip.enable = true;
        neo-tree.enable = true;
        nix.enable = true;
        nvim-autopairs.enable = true;
        nvim-colorizer.enable = true;
        nvim-ufo.enable = true;
        oil.enable = true;
        rainbow-delimiters.enable = true;
        rustaceanvim.enable = true;
        sleuth.enable = true;
        vim-surround.enable = true;
        telescope.enable = true;
        todo-comments.enable = true;
        treesitter.enable = true;
        trim.enable = true;
        vimtex.enable = true;
        web-devicons.enable = true;
        which-key.enable = true;
      };

      extraPlugins = with pkgs.vimPlugins; [
        neodev-nvim
        vim-numbertoggle
      ];
    };
  };
}
