"" Vundle
filetype off
se rtp+=~/.vim/bundle/Vundle.vim
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
Plugin 'mustache/vim-mustache-handlebars' " Javascript Handlebars syntax
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
se ar
se ffs+=mac

" Fancy indentation and such
se ai
se bs=indent,eol,start
se cin
se cino=(0,u0,U0
se cpt-=i
se sta

" Aesthetic
se dy+=lastline
se lsp=0
se noeb
se nojs
se sm

se fo+=j

" Search
se hls
se ic
se is
se scs

se mouse=

" Default indentation
se noet
se sw=8
se sts=0
se ts=8

se nf-=octal

" Statusline
se ls=2
se ru
se sc
se nosmd
se wmnu
"se stl=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

" Scrolling
if !&scrolloff
	se so=1
endif
if !&sidescrolloff
	se siso=5
endif

se sh=/bin/bash

se ttimeout
se ttm=100

" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
	nn <silent> <C-L> :nohlsearch<CR><C-L>
endif

"" Indentation adjustments
au FileType css,html,javascript setl sw=4 ts=4 et
au FileType java,xml setl sw=4 ts=4 et
au FileType make setl sw=8 ts=8 sts=0 noet

" Obligatory
filetype plugin indent on
se nocp
syntax on

" Color scheme
let base16colorspace=256
"se t_Co=256
se bg=dark
colo base16-eighties

" Remove trailing whitespace on save
au BufWritePre * :%s/\s\+$//e

" Disable auto-commenting
au FileType * setl fo-=c fo-=r fo-=o

" Get backups out of the way
se bdir=~/.vim/backup
se dir=~/.vim/swap

"" Grep
" Open Quickfix after grep
au QuickFixCmdPost *grep* cwindow

"" Compilation
" Open Quickfix after make
aug OpenQuickfixWindowAfterMake
    au QuickFixCmdPost [^l]* nested cwindow
    au QuickFixCmdPost    l* nested lwindow
aug END

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
se wig+=*/build/*,*/tmp/*,*.cmd,*.ko,*.mod*,*.o,*.so,*.swp,*.tar*,*.zip

"" Easytags
"let g:easytags_always_enabled = 1
"let g:easytags_async = 1
se tag=./tags;
"let g:easytags_dynamic_files = 1

"" Fugitive
" Delete buffers after leaving (so they don't clog the list)
au BufReadPost fugitive://* se bh=delete

"" Mustache/Handlebars
au FileType html se syn=mustache

"" Rhubarb
se cot-=preview

"" Keybindings
" Leader key
let mapleader = ";"

" Android
nn <Leader>ad :AndroidDevices<CR>
nn <Leader>ae :AndroidEmulator<CR>
nn <Leader>ai :Android installDebug<CR>
nn <Leader>am :Android assembleDebug<CR>
nn <Leader>at :AndroidTest<CR>
nn <Leader>au :AndroidUpdateTags<CR>

" Dispatch
nn <Leader>m :Make<CR>

" Fugitiveackground
nn <Leader>gc :Gcommit<CR>
nn <Leader>gd :Gdiff<CR>
nn <Leader>gr :Gread<CR>
nn <Leader>gs :Gstatus<CR>
nn <Leader>gw :Gwrite<CR>

" Buffer manipulation
se hid
nn <Leader>l :bnext<CR>
nn <Leader>h :bprev<CR>
nn <Leader>q :bp <BAR> bd #<CR>

" IDE navigation
nn <Leader>aa :A<CR>
nn <Leader>gf <C-]>

" Web dev - accounts for delimitMate
im <silent> <C-j> </<C-X><C-O><C-X><C-H><Esc><<

" Quick edits
nn <Leader>eba :e ~/.bash_aliases<CR>
nn <Leader>ebr :e ~/.bashrc<CR>
nn <Leader>en :e ~/.nvimrc<CR>
nn <Leader>ep :e ~/.profile<CR>
nn <Leader>ev :e ~/.vimrc<CR>
nn <Leader>exi :e ~/.xinitrc<CR>
nn <Leader>exp :e ~/.xprofile<CR>

" Reload this config
nn <Leader>r :so ~/.nvimrc<CR>

" Exit Insert mode
im jk <Esc>

" Remap up/down keys to navigate wrapped lines
nn j gj
nn k gk
nn gj j
nn gk k
