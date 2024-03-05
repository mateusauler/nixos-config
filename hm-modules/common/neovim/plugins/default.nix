{ config, lib, pkgs, ... }:

let
  cfg = config.modules.neovim;
in
{
  imports = [
    ./lsp.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      extraPackages = with pkgs; [
        fd
      ];
      plugins = {
        auto-session.enable = true;
        bufferline.enable = true;
        comment-nvim.enable = true;
        diffview.enable = true;
        gitsigns.enable = true;
        lualine.enable = true;
        neo-tree.enable = true;
        nix.enable = true;
        nvim-autopairs.enable = true;
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
