" Use system clipboard
set clipboard=unnamedplus

" Line numbers
set number
set relativenumber

" Tabs
set tabstop=4     " 4 char-wide tab
set softtabstop=0 " Use same length as 'tabstop'
set shiftwidth=0  " Use same length as 'tabstop'

" 2 char-wide overrides
augroup two_space_tab
  autocmd!
  autocmd FileType nix setlocal tabstop=2 expandtab
augroup END