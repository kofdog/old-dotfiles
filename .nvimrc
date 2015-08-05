" Add Vundle packages
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Critical
Plugin 'ap/vim-buftabline'
Plugin 'a.vim'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'vim-scripts/Smart-Tabs'

" Nifty
Plugin 'junegunn/goyo.vim'

call vundle#end()

set showcmd   " Show (partial) command in status line.
set showmatch " Show matching brackets.
set showmode  " Show current mode.
set ruler     " Show the line and column numbers of the cursor.

set noerrorbells " No beeps.
set modeline     " Enable modeline.
set esckeys      " Cursor keys in insert mode.
set linespace=0  " Set line-spacing to minimum.
set nojoinspaces " Prevents inserting two spaces after punctuation on a join (J)

set hlsearch   " Highlight search results.
set ignorecase " Make searching case insensitive
set smartcase  " ... unless the query has capital letters.
set incsearch  " Incremental search.

" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
endif

" Obligatory
filetype plugin indent on

" Leader key
:let mapleader = "\<SPACE>"

" Syntax highlighting
syntax on

" Color scheme
let base16colorspace=256
set background=dark
colorscheme base16-eighties

" Set tab = 8-width tab
set noexpandtab
set softtabstop=0
set shiftwidth=8
set tabstop=8

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
