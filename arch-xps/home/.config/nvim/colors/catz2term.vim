" Vim color file

hi clear

if exists("syntax on")
syntax reset
endif

set t_Co=256
let g:colors_name = "catz2term"


" Define reusable colorvariables.
let s:bg="#ffffff"
let s:fg="#2f2f2f"
let s:fg2="#404040"
let s:fg3="#505050"
let s:fg4="#616161"
let s:bg2="#f8f8f8"
let s:bg3="#aaaaaa"
let s:bg4="#bdbfc0"
let s:keyword="#28728f"
let s:builtin="#636792"
let s:const= "#28766e"
let s:comment="#707070"
let s:func="#935c54"
let s:str="#aa8080"
let s:type="#56724b"
let s:var="#7d6740"
let s:warning="#fa0c0c"
let s:warning2="#fa7b0c"
let s:error="#aa0000"
let s:todo="#ffffff"
let s:cocerrorfg="#cc2020"
let s:floating="#d5e5d5"
let s:cursorline="#e2f9e9"
let s:pmenusel="#95a595"

exe 'hi Normal guifg='s:fg' guibg='s:bg
exe 'hi Cursor guifg='s:bg' guibg='s:fg
exe 'hi CursorLine  guibg='s:cursorline
exe 'hi CursorColumn  guibg='s:bg2
exe 'hi CursorLineNR  gui=bold guifg='s:fg
exe 'hi ColorColumn  guibg='s:bg2
exe 'hi LineNr guifg='s:fg2' guibg='s:bg2
exe 'hi VertSplit guifg='s:bg2' guibg='s:fg3
exe 'hi MatchParen guibg=NONE cterm=underline gui=underline'
exe 'hi StatusLine guifg='s:bg' guibg='s:bg4' gui=bold'
exe 'hi StatusLineNC guifg='s:bg2' guibg='s:bg3
exe 'hi Pmenu guifg='s:fg4' guibg='s:floating
exe 'hi PmenuSel  guibg='s:pmenusel' guifg='s:bg
exe 'hi IncSearch guifg='s:bg' guibg='s:keyword
exe 'hi Search gui=underline guibg=NONE'
exe 'hi Directory guifg='s:const
exe 'hi Folded guifg='s:fg4' guibg='s:bg
exe 'hi Visual guifg='s:bg' guibg='s:fg3
exe 'hi Error guifg='s:fg' guibg='s:error
exe 'hi Todo guifg='s:fg' guibg='s:todo
exe 'hi SignColumn guifg='s:fg' guibg='s:bg

exe 'hi Boolean guifg='s:const
exe 'hi Character guifg='s:const
exe 'hi Comment guifg='s:comment
exe 'hi Conditional guifg='s:keyword
exe 'hi Constant guifg='s:const
exe 'hi Define guifg='s:keyword
exe 'hi DiffAdd guifg=#000000 guibg=#bef6dc gui=bold'
exe 'hi DiffDelete guifg='s:bg2
exe 'hi DiffChange  guibg=#5b76ef guifg=#ffffff'
exe 'hi DiffText guifg=#ffffff guibg=#ff0000 gui=bold'
exe 'hi ErrorMsg guifg='s:warning' guibg='s:bg2' gui=bold'
exe 'hi WarningMsg guifg='s:fg' guibg='s:warning2
exe 'hi Float guifg='s:const
exe 'hi Function guifg='s:func
exe 'hi Identifier guifg='s:type'  gui=italic'
exe 'hi Keyword guifg='s:keyword' gui=bold'
exe 'hi Label guifg='s:var
exe 'hi NonText guifg='s:bg4' guibg='s:bg2
exe 'hi Number guifg='s:const
exe 'hi Operator guifg='s:keyword
exe 'hi PreProc guifg='s:keyword
exe 'hi Special guifg='s:fg
exe 'hi SpecialKey guifg='s:fg2' guibg='s:bg2
exe 'hi Statement guifg='s:keyword' cterm=bold'
exe 'hi StorageClass guifg='s:type'  gui=italic'
exe 'hi String guifg='s:str
exe 'hi Tag guifg='s:keyword
exe 'hi Title guifg='s:fg'  gui=bold'
exe 'hi Todo guifg='s:fg2'  gui=inverse,bold'
exe 'hi Type guifg='s:type
exe 'hi Underlined   gui=underline'
exe 'hi RedrawDebugClear guifg='s:bg
exe 'hi NvimInternalError guibg='s:error

" Python Highlighting
exe 'hi pythonBuiltinFunc guifg='s:builtin

" Go Highlighting
exe 'hi goBuiltins guifg='s:builtin

" CoC
exe 'hi CocErrorSign guifg='s:cocerrorfg
exe 'hi CocErrorFloat guifg='s:error' guibg='s:floating

" Javascript Highlighting
exe 'hi jsBuiltins guifg='s:builtin
exe 'hi jsFunction guifg='s:keyword' gui=bold'
exe 'hi jsGlobalObjects guifg='s:type
exe 'hi jsAssignmentExps guifg='s:var

" Html Highlighting
exe 'hi htmlLink guifg='s:var' gui=underline'
exe 'hi htmlStatement guifg='s:keyword
exe 'hi htmlSpecialTagName guifg='s:keyword

" Markdown Highlighting
exe 'hi mkdCode guifg='s:builtin
