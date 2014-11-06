" PACKAGES

" Add packages to runtime path
execute pathogen#infect()



" AESTHETICS

" Syntax highlighting
syntax on

" Color scheme
"set t_Co=16
let base16colorspace=256
set background=dark
colorscheme base16-monokai



" INDENTING

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



" KEY MAPPINGS

" Map 'jk' to escape when in INSERT mode
:imap jk <Esc>

" Remap up/down keys to navigate wrapped lines
:nnoremap j gj
:nnoremap k gk



" SHORTCUTS

" Open Nerd Tree
:command NT NERDTree

" Switch to Nerd Tree
:map <silent> <C-n> :NERDTreeFocus<CR>
