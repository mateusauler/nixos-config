vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local mapSilent = function(keys, func, modes)
	modes = modes or 'n'
	vim.keymap.set(modes, keys, func, { silent = true })
end

local mapISilent = function(keys, func)
	mapSilent(keys, '<Esc>' .. func .. 'a', 'i')
end

local mapINSilent = function(keys, func)
	mapSilent(keys, func)
	mapISilent(keys, func)
end

mapSilent('<leader>w', ':w<CR>')
mapINSilent('<C-S>',   ':w<CR>')
mapSilent('<leader>q', ':q<CR>')
mapINSilent('<C-Q>',   ':q<CR>')

-- Normal shortcuts
mapISilent('<C-V>',    'p') -- Paste in insert mode
mapINSilent('<C-Z>',   ':undo<CR>')
mapINSilent('<C-S-Z>', ':redo<CR>')

mapISilent('<C-BS>', 'vbd')

-- Buffer commands
mapSilent('<leader>c',   ':bd<CR>') -- Close
mapINSilent('<C-Tab>',   ':bn<CR>') -- Next
mapINSilent('<A-l>',     ':bn<CR>') -- Next
mapINSilent('<C-S-Tab>', ':bp<CR>') -- Previous
mapINSilent('<A-h>',     ':bp<CR>') -- Previous

-- Split
mapSilent('<C-|>',  ':split<CR>') -- Horizontal
mapSilent('<C-\\>', ':vsplit<CR>') -- Vertical
-- Movement
mapSilent('<C-K>',  ':wincmd k<CR>')
mapSilent('<C-J>',  ':wincmd j<CR>')
mapSilent('<C-H>',  ':wincmd h<CR>')
mapSilent('<C-L>',  ':wincmd l<CR>')
