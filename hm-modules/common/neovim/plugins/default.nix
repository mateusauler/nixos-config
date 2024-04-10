{ config, inputs, lib, nixpkgs-channel, pkgs, ... }:

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
    ./lsp.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      # Hacky way of creating a "global" luasnip variable
      extraConfigLuaPre = lib.optionalString cfg-plug.luasnip.enable /* lua */ "local luasnip = require('luasnip')";

      extraPackages = with pkgs; [
        fd
        mercurial
      ];

      globals = lib.optionalAttrs cfg-plug.oil.enable {
        netrw_nogx = 1;
      };

      keymaps = lib.flatten [
        (lib.optional cfg-plug.oil.enable [
          {
            mode = "n";
            key = "-";
            action = "<Cmd>Oil<CR>";
            options.desc = "Oil: Open parent directory";
          }
          {
            mode = [ "n" "x" ];
            key = "gx";
            action = "<Cmd>Browse<CR>";
          }
        ])
      ];

      extraConfigLua = (builtins.readFile ./neo-tree.lua) +
        (lib.optionalString cfg-plug.oil.enable /* lua */ ''
          require("gx").setup({
            handler_options = { search_engine = "duckduckgo" },
          })
        '');

      plugins = {
        auto-session.enable = true;
        bufferline.enable = true;
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
        oil = let
          settings = {
            default_file_explorer = true;
            experimental_watch_for_changes = true;
          };
        in { enable = true; } // (if nixpkgs-channel == "stable" then { extraOptions = settings; } else { inherit settings; });
        rainbow-delimiters.enable = true;
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
      extraPlugins = with pkgs.vimPlugins; lib.flatten [
        (lib.optionals cfg-plug.oil.enable pkgs.vimUtils.buildVimPlugin {
          name = "gx";
          src = inputs.gx;
        })
        vim-numbertoggle
        neodev-nvim
      ];
    };
  };
}
