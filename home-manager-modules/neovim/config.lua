vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local mapSilent = function(keys, func)
	vim.keymap.set('n', keys, func, { silent = true })
end

mapSilent('<leader>w', ':w<CR>')
mapSilent('<leader>q', ':q<CR>')
mapSilent('<C-Q>',     ':q<CR>')

-- Buffer commands
mapSilent('<leader>c', ':bd<CR>') -- Close
mapSilent('<C-Tab>',   ':bn<CR>') -- Next
mapSilent('<A-Right>', ':bn<CR>') -- Next
mapSilent('<C-S-Tab>', ':bp<CR>') -- Previous
mapSilent('<A-Left>',  ':bp<CR>') -- Previous

-- Split
mapSilent('<C-|>',  ':split<CR>') -- Horizontal
mapSilent('<C-\\>', ':vsplit<CR>') -- Vertical
-- Movement
mapSilent('<C-K>',  ':wincmd k<CR>')
mapSilent('<C-J>',  ':wincmd j<CR>')
mapSilent('<C-H>',  ':wincmd h<CR>')
mapSilent('<C-L>',  ':wincmd l<CR>')
