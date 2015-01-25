" Add Vundle packages
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'a.vim'
Plugin 'ap/vim-buftabline'
"Plugin 'skammer/vim-css-color'
"Plugin 'Valloric/YouCompleteMe'
"Plugin 'honza/vim-snippets'
"Plugin 'SirVer/ultisnips'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
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
colorscheme base16-default

" Set tab = 4-width tab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

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
