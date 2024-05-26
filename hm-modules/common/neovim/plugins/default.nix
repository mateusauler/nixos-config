{
  config,
  lib,
  nixpkgs-channel,
  pkgs,
  ...
}:

let
  cfg = config.modules.neovim;

  plugins = {
    stable = {
      comment-nvim.enable = true;
      rust-tools = {
        enable = true;
        server = {
          check.command = "clippy";
          typing.autoClosingAngleBrackets.enable = true;
        };
      };
    };
    unstable = {
      comment.enable = true;
      friendly-snippets.enable = true;
      dap.enable = true;
      rustaceanvim.enable = true;
      vimtex = {
        enable = true;
        texlivePackage = null;
        settings = lib.optionalAttrs config.programs.zathura.enable { view_method = "zathura"; };
      };
    };
  };

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

      plugins = {
        auto-session.enable = true;
        bufferline.enable = true;
        cursorline = {
          enable = true;
          cursorline = {
            timeout = 450;
            number = true;
          };
          cursorword.enable = false;
        };
        diffview.enable = true;
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
        surround.enable = true;
        telescope.enable = true;
        todo-comments.enable = true;
        treesitter = {
          enable = true;
          indent = true;
          nixvimInjections = true;
        };
        which-key.enable = true;
      } // plugins.${nixpkgs-channel} or { };

      extraPlugins = with pkgs.vimPlugins; [
        neodev-nvim
        vim-numbertoggle
      ];
    };
  };
}
