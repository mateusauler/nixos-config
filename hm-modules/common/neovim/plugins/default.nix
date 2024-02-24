{ config, lib, pkgs, ... }:

let
  cfg = config.modules.neovim;
  requireAndSetupLua = plugin: { name ? (lib.removeSuffix ".nvim" plugin.pname), args ? "" }:
    {
      inherit plugin;
      type = "lua";
      config = "require('${name}').setup(${args})";
    };
in
{
  config = lib.mkIf cfg.enable {
    programs.neovim = {
      extraPackages = with pkgs; [
        fd
        luajitPackages.lua-lsp
        rnix-lsp
        tree-sitter
        wl-clipboard
      ];

      plugins = with pkgs.vimPlugins; [
        vim-numbertoggle
        (requireAndSetupLua diffview-nvim { })

        {
          plugin = alpha-nvim;
          type = "lua";
          config = ''
            local dotscloned = ${toString config.dots.clone}
            local dotspath = '${config.dots.path}'
            ${builtins.readFile ./alpha-nvim.lua}
          '';
        }

        (requireAndSetupLua bufferline-nvim { })
        (requireAndSetupLua nvim-web-devicons { })

        (requireAndSetupLua lualine-nvim { args = "{ icons_enabled = true }"; })
        {
          plugin = neo-tree-nvim;
          type = "lua";
          config = builtins.readFile ./neo-tree.lua;
        }

        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = builtins.readFile ./treesitter.lua;
        }

        vim-nix
        neodev-nvim

        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = builtins.readFile ./lsp.lua;
        }

        (requireAndSetupLua comment-nvim { name = "Comment"; })
        (requireAndSetupLua auto-session { })
        (requireAndSetupLua gitsigns-nvim { })

        (requireAndSetupLua which-key-nvim { })
      ];
    };
  };
}
