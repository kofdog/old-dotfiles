" Add packages to runtime path
execute pathogen#infect()

" Syntax highlighting
syntax on

" Color scheme
let base16colorspace=256
set background=dark
colorscheme base16-monokai

" Auto indent
filetype plugin indent on

" Set tab = 4-spaces...
set tabstop=8
set shiftwidth=4
set softtabstop=4
set expandtab

" ...except in Makefiles: tab = 8-width tab
if has("autocmd")
	autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
endif

" Exit insert mode
:imap jk <Esc>

" Delete/change up to underscore/hyphen
:nmap du dt_
:nmap cu ct_

:nmap di dt-
:nmap ci ct-

" Remap up/down keys to navigate wrapped lines
:nnoremap j gj
:nnoremap k gk

" Open Nerd Tree
:command NT NERDTree

" Switch to Nerd Tree
:map <silent> <C-n> :NERDTreeFocus<CR>
