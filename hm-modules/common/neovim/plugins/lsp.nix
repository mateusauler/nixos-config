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
lib.mkIf cfg.enable {
  programs.nixvim.plugins = {
    clangd-extensions.enable = cfg-plug.lsp.enable;
    lsp-lines.enable = true;
    lsp = {
      onAttach = # lua
        ''
          local bufmap = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
          end

          bufmap('<leader>r', vim.lsp.buf.rename,      'Rename symbol')
          bufmap('<leader>a', vim.lsp.buf.code_action, 'Code action')

          bufmap('gd',        vim.lsp.buf.definition,      'Go to definition')
          bufmap('gD',        vim.lsp.buf.declaration,     'Go to declaration')
          bufmap('gI',        vim.lsp.buf.implementation,  'Go to implementation')
          bufmap('<leader>D', vim.lsp.buf.type_definition, 'Go to type definition')

          bufmap('gr',        require('telescope.builtin').lsp_references,                'Telescope: references')
          bufmap('<leader>s', require('telescope.builtin').lsp_document_symbols,          'Telescope: document symbols')
          bufmap('<leader>S', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Telescope: dynamic workspace symbols')

          bufmap('K', vim.lsp.buf.hover, 'Hover')

          bufmap('<leader>F', vim.lsp.buf.format, 'Format')
        '';
      servers = {
        bashls.enable = true;
        clangd.enable = true;
        html.enable = true;
        java_language_server.enable = true;
        jsonls.enable = true;
        lua_ls.enable = true;
        nixd = {
          enable = true;
          settings = {
            diagnostic.suppress = [ "sema-escaping-with" ];
            formatting.command = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
          };
        };
        pylsp = {
          enable = true;
          settings.plugins.black.enable = true;
        };
        pyright.enable = true;
        texlab.enable = true;
      };
    };
  };
}
