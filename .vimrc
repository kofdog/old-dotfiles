" Add Vundle packages
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Critical
Plugin 'scrooloose/syntastic'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-surround'
Plugin 'vim-scripts/Smart-Tabs'

" Nifty
Plugin 'ap/vim-buftabline'
Plugin 'a.vim'
Plugin 'tpope/vim-repeat'
Plugin 'junegunn/goyo.vim'

" Snippets
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'honza/vim-snippets'
"Plugin 'SirVer/ultisnips'

call vundle#end()

" System info required for later
let s:kern = system("uname -r")
let s:kernfixed = substitute(s:kern, "\n", "", "")
let s:kernpath = '/lib/modules/' . s:kernfixed . '/build/include'

" Syntastic
" TODO: Figure out how to add include paths
let g:syntastic_c_check_header = 1
let g:syntastic_cpp_check_header = 1
let g:syntastic_java_javac_classpath = "~/Android/Sdk/platforms/android-21/*.jar:~/AndroidStudioProjects/Sandbox/app/src/main"

" Obligatory
filetype plugin indent on

" Leader key
:let mapleader = ";"

" Syntax highlighting
syntax on

" Special characters
inoremap <C-d> <C-k>
"set digraph
"inoremap <C-d> <C-h>

" Color scheme
let base16colorspace=256
set background=dark
colorscheme base16-eighties

" Set tab = 4-width tab
set noexpandtab
set softtabstop=0
set shiftwidth=4
set tabstop=4

" Use tabs for indentation, spaces for alignment
set cindent
set cinoptions=(0,u0,U0
set smarttab

" ...except in Makefiles: tab = 8-width tab
if has("autocmd")
	autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
endif

" Remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Path
let s:pathcommand = 'set path+=' . s:kernpath
exec s:pathcommand

" Get backups out of the way
set backupdir=~/.vim/backup
set directory=~/.vim/swap

" Buffer manipulation
set hidden
nnoremap <Leader>l :bnext<CR>
nnoremap <Leader>h :bprev<CR>
nnoremap <Leader>q :bp <BAR> bd #<CR>

" Exit Insert mode
imap jk <Esc>

" Move in Insert mode
inoremap <C-h> <left>
inoremap <C-j> <down>
inoremap <C-k> <up>
inoremap <C-l> <right>

" Delete/change up to underscore/hyphen
nmap du dt_
nmap cu ct_

nmap di dt-
nmap ci ct-

" Remap up/down keys to navigate wrapped lines
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
