" PACKAGES

" Add packages to runtime path
execute pathogen#infect()



" AESTHETICS

" Syntax highlighting
syntax on

" Color scheme
"set t_Co=16
"set background=dark
colorscheme base16-default
"if $TERM == 'rxvt-256color'
"    colorscheme Tomorrow-Night
"elseif $TERM == 'xterm-256color'
"    colorscheme Tomorrow
"endif



" INDENTING

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
