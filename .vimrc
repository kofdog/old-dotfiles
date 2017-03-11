"" Vundle
filetype off
se rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'chriskempson/base16-vim'          " colors
Plugin 'christoomey/vim-tmux-navigator'   " seamless navigation
Plugin 'ctrlpvim/ctrlp.vim'               " fuzzy finder
Plugin 'edkolev/tmuxline.vim'             " tmux statusline
Plugin 'hsanson/vim-android'              " Android/Gradle integration
Plugin 'jelera/vim-javascript-syntax'     " better syntax highlighting for JS
Plugin 'morhetz/gruvbox'                  " colors
Plugin 'mustache/vim-mustache-handlebars' " Javascript Handlebars syntax
Plugin 'octol/vim-cpp-enhanced-highlight' " better syntax highlighting for C++
Plugin 'othree/html5.vim'                 " syntax highlighting for HTML5
Plugin 'pangloss/vim-javascript'          " better syntax/indent for JS
Plugin 'tpope/vim-commentary'             " comments
Plugin 'tpope/vim-dispatch'               " asynchronous compilation in tmux
Plugin 'tpope/vim-fugitive'               " git integration
Plugin 'tpope/vim-obsession'              " make persistent sessions
Plugin 'tyrannicaltoucan/vim-quantum'     " colors
Plugin 'vim-airline/vim-airline'          " aesthetics
Plugin 'vim-airline/vim-airline-themes'   " colors
Plugin 'vim-scripts/a.vim'                " header/src switching
Plugin 'vim-scripts/Smart-Tabs'           " tabs:indentation::spaces:alignment

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
se cc=81
se dy+=lastline
se lsp=0
se noeb
se nojs
se sm

se fo+=j
se hid

" Search
se nohls
se ic
se is
se scs
se wig=**/app/build/**,*.o,*.obj

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

se sh=/bin/bash

se ttimeout
se ttm=100

"" Indentation adjustments
au FileType c,cpp,make setl sw=8 ts=8 sts=0 noet cc=81 nu
au FileType css,html,javascript setl sw=2 ts=2 et cc=81 nu
au FileType java,xml setl sw=4 ts=4 et cc=101 nu
au FileType haskell setl sw=4 ts=4 et cc=80 nu
au FileType python setl sw=4 ts=4 et cc=80 nu

" Obligatory
filetype plugin indent on
se nocp
syntax on

" Color scheme
let base16colorspace=256
se bg=dark
" let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
colo base16-materia
" colo gruvbox
" colo quantum
"if has("termguicolors")
"	set termguicolors
"endif

" Remove trailing whitespace on save
au BufWritePre * :%s/\s\+$//e

" Disable auto-commenting
au FileType * setl fo-=c fo-=r fo-=o

" Get backups out of the way
se bdir=~/.vim/backup//
se dir=~/.vim/swap//
se noswf

"" Path/Tags
" Project workspace
se path=$PWD/**
se tag+=./tags

" Linux kernel
"let s:kern = system("uname -r")
"let s:kernpath = 'se path+=/lib/modules/' . s:kern . '/build/include'
"let s:kerncommand = substitute(s:kernpath, '\n', '', 'g')
"exec s:kerncommand
se path+=~/linux/include
se path+=~/linux/arch/x86/include
se tag+=~/linux/tags

se path+=/usr/include
"se tag+=/usr/include/tags

"" Airline
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tmuxline#enabled = 0
let g:airline_powerline_fonts = 1
let g:airline_theme='base16'
" let g:airline_theme='gruvbox'
" let g:airline_theme='quantum'

"" Android
let g:android_sdk_tags = '$PWD/tags'
let g:gradle_daemon = 1
let g:gradle_quickfix_show = 1

"" CtrlP
let g:ctrlp_show_hidden = 1
nn <c-o> :CtrlPBuffer<CR>

"" Mustache/Handlebars
au FileType html se syn=mustache

"" Tmuxline
" let g:tmuxline_preset = {
" 	\'a'       : '#S',
" 	\'win'     : ['#I', '#W'],
" 	\'cwin'    : ['#I', '#W'],
" 	\'y'       : ['%Y', '%H:%M'],
" 	\'z'       : '#H'
" 	\'options' : {'status-justify' : 'left'}}

"" Keybindings
" Leader key
let mapleader = ";"

" Buffer manipulation
nn gb :bn<CR>
nn gB :bp<CR>
nn <Leader>bd :b#\|bd#<CR>

" Exit Insert mode
im jk <Esc>
