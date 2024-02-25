vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local mapSilent = function(keys, func, modes, desc)
	params = { silent = true }
	if desc ~= nil then params['desc'] = desc end

	vim.keymap.set(modes, keys, func, params)
end

local mapISilent = function(keys, func, desc)
	mapSilent(keys, '<Esc>' .. func .. 'a', 'i', desc)
end

local mapNSilent = function(keys, func, desc)
	mapSilent(keys, func, 'n', desc)
end

local mapINSilent = function(keys, func, desc)
	mapISilent(keys, func, desc)
	mapNSilent(keys, func, desc)
end

mapNSilent('<leader>w', ':w<CR>', 'Save')
mapINSilent('<C-S>',    ':w<CR>', 'Save')
mapNSilent('<leader>q', ':q<CR>', 'Quit')
mapINSilent('<C-Q>',    ':q<CR>', 'Quit')

-- Normal shortcuts
mapISilent('<C-V>',    'p',         'Paste from clipboard')
mapINSilent('<C-Z>',   ':undo<CR>', 'Undo last action')
mapINSilent('<C-S-Z>', ':redo<CR>', 'Redo last undone action')

mapISilent('<C-BS>', 'vbd', 'Delete previous word')

-- Buffer commands
mapNSilent('<leader>c',  ':bd<CR>', 'Close buffer')
mapINSilent('<C-Tab>',   ':bn<CR>', 'Next buffer')
mapINSilent('<A-l>',     ':bn<CR>', 'Next buffer')
mapINSilent('<C-S-Tab>', ':bp<CR>', 'Previous buffer')
mapINSilent('<A-h>',     ':bp<CR>', 'Previous buffer')

-- Split
mapNSilent('<C-|>',  ':split<CR>',  'Horizontal split')
mapNSilent('<C-\\>', ':vsplit<CR>', 'Vertical split')
-- Movement
mapNSilent('<C-K>',  ':wincmd k<CR>', 'Move to split above')
mapNSilent('<C-J>',  ':wincmd j<CR>', 'Move to split below')
mapNSilent('<C-H>',  ':wincmd h<CR>', 'Move to split left')
mapNSilent('<C-L>',  ':wincmd l<CR>', 'Move to split right')
