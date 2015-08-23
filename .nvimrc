"" Vundle
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'a.vim'                            " header/library switching
Plugin 'bling/vim-airline'                " awesome status line
"Plugin 'bling/vim-bufferline'             " show buffers in statusline
Plugin 'chriskempson/base16-vim'          " colors
Plugin 'hsanson/vim-android'              " Android integration
Plugin 'jelera/vim-javascript-syntax'     " better syntax highlighting for JS
Plugin 'jnurmine/Zenburn'                 " colors
Plugin 'junegunn/goyo.vim'                " distraction-free editing
Plugin 'kien/ctrlp.vim'                   " file finding
Plugin 'octol/vim-cpp-enhanced-highlight' " better syntax highlighting for C++
Plugin 'pangloss/vim-javascript'          " better syntax/indent for JS
Plugin 'Raimondi/delimitMate'             " automatic closing parens, et al.
Plugin 'tpope/vim-commentary'             " comments
Plugin 'tpope/vim-dispatch'               " asynchronous compilation in tmux
Plugin 'tpope/vim-eunuch'                 " UNIX commands in Vim
Plugin 'tpope/vim-fugitive'               " git integration
Plugin 'tpope/vim-repeat'                 " supporting . for plugins
Plugin 'tpope/vim-rhubarb'                " Github integration
Plugin 'tpope/vim-surround'               " surrounding brackets/quotes/etc.
"Plugin 'Valloric/MatchTagAlways'          " HTML tag highlighting
"Plugin 'vim-scripts/HTML-AutoCloseTag'    " automatic HTML tag closing
Plugin 'vim-scripts/Smart-Tabs'           " tabs:indentation::spaces:alignment
"Plugin 'xolox/vim-easytags'               " Exuberant Ctags integration
Plugin 'xolox/vim-misc'                   " dependency for Easytags

call vundle#end()

"" Settings
" File reading
set autoread
set fileformats+=mac

" Fancy indentation and such
set autoindent
set backspace=indent,eol,start
set cindent
set cinoptions=(0,u0,U0
set complete-=i
set smarttab

" Aesthetic
set display+=lastline
set linespace=0
set noerrorbells
set nojoinspaces
set showmatch

set formatoptions+=j

" Search
set hlsearch
set ignorecase
set incsearch
set smartcase

set mouse=

" Default indentation
set noexpandtab
set shiftwidth=8
set softtabstop=0
set tabstop=8

set nrformats-=octal

" Statusline
set laststatus=2
set ruler
set showcmd
set noshowmode
set wildmenu
"set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

" Scrolling
if !&scrolloff
	set scrolloff=1
endif
if !&sidescrolloff
	set sidescrolloff=5
endif

set shell=/bin/bash

set ttimeout
set ttimeoutlen=100

" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
	nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
endif

"" Indentation adjustments
autocmd FileType css setlocal shiftwidth=4 tabstop=4 expandtab
autocmd FileType html setlocal shiftwidth=4 tabstop=4 expandtab
autocmd FileType javascript setlocal shiftwidth=4 tabstop=4 expandtab
autocmd FileType make setlocal shiftwidth=8 tabstop=8 softtabstop=0 noexpandtab

" Obligatory
filetype plugin indent on
set nocp
syntax on

" Color scheme
let base16colorspace=256
"set t_Co=256
set background=dark
colorscheme base16-eighties

" Remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Disable auto-commenting
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Get backups out of the way
set backupdir=~/.vim/backup
set directory=~/.vim/swap

"" Grep
" Open Quickfix after grep
autocmd QuickFixCmdPost *grep* cwindow

"" Compilation
" Open Quickfix after make
augroup OpenQuickfixWindowAfterMake
    autocmd QuickFixCmdPost [^l]* nested cwindow
    autocmd QuickFixCmdPost    l* nested lwindow
augroup END

"" Airline
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#tabline#enabled = 1

"" Android
let g:android_sdk_path = '~/Android/Sdk'
let g:gradle_path = '/usr/share/java/gradle'

"" Bufferline
let g:bufferline_echo = 0
let g:bufferline_rotate = 0

" Separators
let g:bufferline_active_buffer_left = ''
let g:bufferline_active_buffer_right = ''

let g:bufferline_show_bufnr = 0

"" Ctrl-P
let g:ctrlp_map = '<Leader>o'
let g:ctrlp_show_hidden = 1
let g:ctrlp_working_path_mode = 'rc'
set wildignore+=*/tmp/*,*.cmd,*.ko,*.mod*,*.o,*.so,*.swp,*.tar*,*.zip

"" Easytags
"let g:easytags_always_enabled = 1
"let g:easytags_async = 1
:set tags=./tags;
"let g:easytags_dynamic_files = 1

"" Fugitive
" Delete buffers after leaving (so they don't clog the list)
autocmd BufReadPost fugitive://* set bufhidden=delete

"" Rhubarb
set completeopt-=preview

"" Keybindings
" Leader key
:let mapleader = ";"

" Android
nnoremap <Leader>ai :Android installDebug<CR>
nnoremap <Leader>am :Android assembleDebug<CR>
nnoremap <Leader>at :AndroidUpdateTags<CR>

" Dispatch
nnoremap <Leader>m :Make<CR>

" Fugitive
nnoremap <Leader>gc :Gcommit<CR>
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>gr :Gread<CR>
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gw :Gwrite<CR>

" Buffer manipulation
set hidden
nnoremap <Leader>l :bnext<CR>
nnoremap <Leader>h :bprev<CR>
nnoremap <Leader>q :bp <BAR> bd #<CR>

" IDE navigation
nnoremap <Leader>aa :A<CR>
nnoremap <Leader>gf <C-]>

" Web dev - accounts for delimitMate
imap <silent> <C-j> </<C-X><C-O><C-X><C-H><Esc><<

" Exit Insert mode
imap jk <Esc>

" Remap up/down keys to navigate wrapped lines
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
