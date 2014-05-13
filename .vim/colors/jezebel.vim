" local syntax file - set colors on a per-machine basis:
" vim: tw=0 ts=4 sw=4
" Vim color file
" Maintainer: heru-ra
" Last Change:    2014 May 12

hi clear
set background=dark
if exists("syntax_on")
    syntax reset
endif
let g:colors_name = "jezebel"

hi Comment ctermfg=4 guifg=#808080
hi Constant ctermfg=4 guifg=#00ffff gui=none
hi Identifier ctermfg=7 cterm=none guifg=#00c0c0
hi Statement ctermfg=2 guifg=#c0c000 gui=bold
hi PreProc ctermfg=7 guifg=#00ff00
hi Type ctermfg=3 guifg=#00c000
hi Special ctermfg=12 guifg=#0000ff
hi Error ctermbg=9 guibg=#ff0000
hi Todo ctermfg=4 ctermbg=3 guifg=#000080 guibg=#c0c000
hi Directory ctermfg=2 guifg=#00c000
hi StatusLine ctermfg=11 ctermbg=12 cterm=none guifg=#ffff00 guibg=#0000ff gui=none
hi Normal guifg=#ffffff guibg=#000000
hi Search ctermbg=3 guibg=#c0c000
hi htmlLink ctermfg=7 cterm=none

hi String ctermfg=1
hi link Character Constant
hi link Number Constant
hi link Boolean Constant
hi link Float Number
hi link Function Identifier
hi link Conditional Statement
hi link Repeat Statement
hi link Label Statement
hi Operator ctermfg=7
hi link Keyword Statement
hi link Exception Statement
hi link Include PreProc
hi link Define PreProc
hi link Macro PreProc
hi link PreCondit PreProc
hi link StorageClass Type
hi link Structure Type
hi link Typedef Type
hi link Tag Special
hi link SpecialChar Special
hi link Delimiter Special
hi link SpecialComment Special
hi link Debug Special
