{ config, lib, nixpkgs-channel, pkgs, ... }:

let
  cfg = config.modules.neovim;
in
lib.mkIf cfg.enable {
  programs.nixvim.plugins.lsp = {
    enable = true;
    onAttach = /* lua */ ''
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

      local format = function(_) vim.lsp.buf.format() end
      vim.api.nvim_buf_create_user_command(bufnr, 'Format', format, {})
      bufmap('<leader>f', format, 'Format')
    '';
    servers = {
      bashls.enable = true;
      html.enable = true;
      java-language-server.enable = true;
      jsonls.enable = true;
      lua-ls.enable = true;
      nixd.enable = true;
      texlab.enable = true;
      yamlls.enable = true;
    } // lib.optionalAttrs (nixpkgs-channel == "stable") {
      rust-analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
        settings.workspace.symbol.search = {
          kind = "all_symbols";
          scope = "workspace_and_dependencies";
        };
      };
    };
  };
}
