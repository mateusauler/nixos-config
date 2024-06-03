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
    ./eyeliner.nix
    ./lsp.nix
    ./neo-tree.nix
    ./oil.nix
    ./telescope.nix
    ./ufo.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      # Hacky way of creating a "global" luasnip variable
      extraConfigLuaPre = lib.optionalString cfg-plug.luasnip.enable "local luasnip = require('luasnip')";

      extraPackages = with pkgs; [
        cargo
        rustc
      ];

      keymaps = lib.optionals config.programs.nixvim.plugins.flash.enable [
        { key = "s";     mode = [ "n" "x" "o" ]; action.__raw = "require('flash').jump";              options.desc = "Flash"; }
        { key = "S";     mode = [ "n" "x" "o" ]; action.__raw = "require('flash').treesitter";        options.desc = "Flash Treesitter"; }
        { key = "r";     mode = "o";             action.__raw = "require('flash').remote";            options.desc = "Remote Flash"; }
        { key = "R";     mode = [ "o" "x" ];     action.__raw = "require('flash').treesitter_search"; options.desc = "Treesitter Search"; }
        { key = "<C-s>"; mode = "c";             action.__raw = "require('flash').toggle";            options.desc = "Toggle Flash Search"; }
        { key = "<C-s>"; mode = [ "n" "x" "o" ]; action = "s"; }
      ];

      plugins = {
        auto-session.enable = true;
        bufferline.enable = true;
        comment.enable = true;
        cursorline = {
          enable = true;
          cursorline = {
            timeout = 450;
            number = true;
          };
          cursorword.enable = false;
        };
        dap.enable = true;
        diffview.enable = true;
        flash = {
          enable = true;
          jump = {
            autojump = true;
            nohlsearch = true;
          };
        };
        friendly-snippets.enable = true;
        gitsigns.enable = true;
        illuminate.enable = true;
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
        surround.enable = true;
        telescope.enable = true;
        todo-comments.enable = true;
        treesitter = {
          enable = true;
          indent = true;
          nixvimInjections = true;
        };
        trim.enable = true;
        vimtex = {
          enable = true;
          texlivePackage = null;
          settings = lib.optionalAttrs config.programs.zathura.enable { view_method = "zathura"; };
        };
        which-key.enable = true;
      };

      extraPlugins = with pkgs.vimPlugins; [
        neodev-nvim
        vim-numbertoggle
      ];
    };
  };
}
