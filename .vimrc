" Add packages to runtime path
execute pathogen#infect()

" Syntax highlighting
syntax on

" Line numbers
set number
set numberwidth=1

" Color scheme
colorscheme default
set background=dark
"se t_Co=256

" Auto indent
filetype plugin indent on

" Set tab = 4 spaces...
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" ...except in Makefiles: tab = 8-space tab
if has("autocmd")
	autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
endif

" Map 'jk' to escape when in INSERT mode
:imap jk <Esc>



" SHORTCUTS

" Open Nerd Tree
:command NT NERDTree

" Switch to Nerd Tree
:map <silent> <C-n> :NERDTreeFocus<CR>

" Remap up/down keys to navigate wrapped lines
:nnoremap j gj
:nnoremap k gk
