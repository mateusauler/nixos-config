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

        # TODO: Configure individual sources
        nvim-cmp = {
          enable = true;
          sources = [
            { name = "buffer"; }
            { name = "calc"; }
            { name = "fish"; }
            { name = "latex-symbols"; }
            { name = "luasnip"; }
            { name = "nvim-lsp"; }
            { name = "nvim-lsp-document-symbol"; }
            { name = "nvim-lsp-signature-help"; }
            { name = "path"; }
            { name = "treesitter"; }
          ];
          mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = {
              action = /* lua */ ''
                function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  ${lib.optionalString config.programs.nixvim.plugins.luasnip.enable /* lua */ ''
                  elseif luasnip.expandable() then
                    luasnip.expand()
                  elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()''}
                  else
                    fallback()
                  end
                end
              '';
              modes = [ "i" "s" ];
            };
          };
        };

        comment-nvim.enable = true;
        diffview.enable = true;
        gitsigns.enable = true;
        lualine.enable = true;
        luasnip.enable = true;
        neo-tree.enable = true;
        nix.enable = true;
        nvim-autopairs.enable = true;
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
