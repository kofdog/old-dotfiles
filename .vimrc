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
"Plugin 'skammer/vim-css-color'
"Plugin 'Valloric/YouCompleteMe'

" Snippets
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'honza/vim-snippets'
"Plugin 'SirVer/ultisnips'

call vundle#end()

" YouCompleteMe
"let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
"
"let g:ycm_key_list_select_completion = ['<TAB>']
"let g:ycm_key_list_previous_completion = ['<C-a>']

" UltiSnips
"let g:UltiSnipsUsePythonVersion = 2
"
"let g:UltiSnipsExpandTrigger = '<c-j>'
"let g:UltiSnipsJumpForwardTrigger = '<c-n>'
"let g:UltiSnipsJumpBackwardTrigger = '<c-m>'
"
"let g:UltiSnipsEditSplic = 'vertical'

" Obligatory
filetype plugin indent on

" Leader key
:let mapleader = ";"

" Syntax highlighting
syntax on

" Special characters
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
