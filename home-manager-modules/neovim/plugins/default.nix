{ config, custom, lib, pkgs, ... }:

let
  cfg = config.modules.neovim;
  requireAndSetup = { plugin, type ? "lua", name ? null }:
    let
      n = if name == null then (lib.removeSuffix ".nvim" plugin.pname) else name;
    in
    {
      inherit plugin type;
      config = "require('${n}').setup()";
    };
  inherit (custom) dots-path;
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
        (requireAndSetup { plugin = diffview-nvim; })

        {
          plugin = alpha-nvim;
          type = "lua";
          config = ''
            local dotspath = '${dots-path}'
            ${builtins.readFile ./alpha-nvim.lua}
          '';
        }

        (requireAndSetup { plugin = bufferline-nvim; })
        (requireAndSetup { plugin = nvim-web-devicons; })

        {
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            require("lualine").setup({
              icons_enabled = true,
            })
          '';
        }
        {
          plugin = neo-tree-nvim;
          type = "lua";
          config = builtins.readFile ./neo-tree.lua;
        }

        nvim-treesitter.withAllGrammars
        vim-nix
        neodev-nvim

        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = builtins.readFile ./lsp.lua;
        }

        (requireAndSetup { plugin = comment-nvim; name = "Comment"; })
        (requireAndSetup { plugin = auto-session; })
        (requireAndSetup { plugin = gitsigns-nvim; })
      ];
    };
  };
}
