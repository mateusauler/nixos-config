local on_attach = function(_, bufnr)

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
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

require('neodev').setup()
require('lspconfig').lua_ls.setup {
	on_attach = on_attach,
	capabilities = capabilities,
	root_dir = function()
		return vim.loop.cwd()
	end,
	cmd = { "lua-lsp" },
	settings = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	}
}

require('lspconfig').rnix.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
