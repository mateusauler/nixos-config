{ config, lib, nixpkgs-channel, pkgs, ... }:

let
  cfg = config.modules.neovim;

  plugins = {
    stable = { };
    unstable = {
      friendly-snippets.enable = true;
      vimtex = {
        enable = true;
        texlivePackage = null;
        settings = lib.optionalAttrs config.programs.zathura.enable { view_method = "zathura"; };
      };
    };
  };
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
        cursorline = {
          enable = true;
          cursorline = {
            timeout = 0;
            number = true;
          };
          cursorword.enable = false;
        };
        diffview.enable = true;
        gitsigns.enable = true;
        illuminate.enable = true;
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
          # FIXME: Use mkRaw helper once I figure out how to get helpers working
          defaults.vimgrep_arguments.__raw = /* lua */ ''
            (function()
              local telescopeConfig = require("telescope.config")
              local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
              table.insert(vimgrep_arguments, "--hidden")
              table.insert(vimgrep_arguments, "--glob")
              table.insert(vimgrep_arguments, "!**/.git/*")
              return vimgrep_arguments
            end)()
          '';
          extraOptions.pickers.find_files.find_command = [ "rg" "--files" "--hidden" "--glob" "!**/.git/*" ];
        };
        todo-comments.enable = true;
        treesitter = {
          enable = true;
          indent = true;
          nixvimInjections = true;
        };
        which-key.enable = true;
      } // plugins.${nixpkgs-channel} or { };

      extraPlugins = with pkgs.vimPlugins; [
        vim-numbertoggle
        neodev-nvim
      ];
    };
  };
}
