{ config, lib, pkgs, ... }:

let
  cfg = config.modules.neovim;
  requireAndSetupLua = { plugin, name ? (lib.removeSuffix ".nvim" plugin.pname), args ? "" }:
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
        luajitPackages.lua-lsp
        rnix-lsp
        wl-clipboard
      ];

      plugins = with pkgs.vimPlugins; [
        vim-numbertoggle
        (requireAndSetupLua { plugin = diffview-nvim; })

        {
          plugin = alpha-nvim;
          type = "lua";
          config = ''
            local dotscloned = ${if config.dots.clone then "true" else "false"}
            local dotspath = '${config.dots.path}'
            ${builtins.readFile ./alpha-nvim.lua}
          '';
        }

        (requireAndSetupLua { plugin = bufferline-nvim; })
        (requireAndSetupLua { plugin = nvim-web-devicons; })

        (requireAndSetupLua { plugin = lualine-nvim; args = "{ icons_enabled = true }"; })
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

        (requireAndSetupLua { plugin = comment-nvim; name = "Comment"; })
        (requireAndSetupLua { plugin = auto-session; })
        (requireAndSetupLua { plugin = gitsigns-nvim; })
      ];
    };
  };
}
