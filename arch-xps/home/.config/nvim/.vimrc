"let mapleader = ','

call plug#begin('~/.vim/plugged')

" Navigation
Plug 'https://github.com/scrooloose/nerdtree.git'
Plug 'wincent/command-t'
Plug 'mileszs/ack.vim'

" Misc
Plug 'https://github.com/xolox/vim-misc.git'

" Completion/PEP-8
Plug 'nvie/vim-flake8'

" Python
Plug 'https://github.com/plytophogy/vim-virtualenv'

call plug#end()

" Basic stuff
  set nocompatible
  filetype plugin on
  set encoding=utf-8
  syntax on
  set hidden
  set wildmenu
  set ruler
  set vb t_vb=
  set number
  set tabstop=2
  set shiftwidth=2
  set softtabstop=2
  set expandtab
  set history=200
  set guicursor+=a:blinkon0
  set noswapfile
  set cc=80

" Style
  set background=light
  if has("gui_running")
    set t_Co=256
    "colorscheme soft-stone
    colorscheme catz2
    set termguicolors
    set guifont=Inconsolata\ 12
    set guioptions+=lrbmTLce
    set guioptions-=lrbmTLce
    set guioptions+=c
  else
    set t_Co=256
    colorscheme catz2term
    set termguicolors
  endif

" Highlight search and use C-l to disable highlighting until the next search
"  set hlsearch
"  nnoremap <leader>l :noh<CR><C-l>

" Open new split in the correct direction
  set splitbelow splitright

" Force N lines when reaching the top or the bottom of the screen
  set so=7

" Navigation without C-w first
  nnoremap <C-h> <C-w>h
  nnoremap <C-j> <C-w>j
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l

" Disable comment on newline
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Enable autocompletion:
  set wildmode=longest,list,full

" Automatically deletes all trailing whitespace on save.
	autocmd BufWritePre * %s/\s\+$//e

" Remap clipboard copy-paste keys
  vnoremap <leader>y "+y
  vnoremap <leader>d "+d
  nnoremap <leader>p "+p

" Experimental stuff

" Nerd tree
	map <leader>N :NERDTreeToggle<CR>
	map <leader>n :NERDTreeFocus<CR>
	autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") &&
    \ b:NERDTree.isTabTree()) | q | endif

" When there is no filetype-specific indenting enabled,
" keep the same indent as the current line
"  set autoindent

" Disable the autoindent
  filetype indent off

" Python
  let python_highlight_all=1
  autocmd BufWritePost *.py call Flake8()
  let g:flake8_show_in_gutter=1
  autocmd Filetype python setlocal expandtab tabstop=4 shiftwidth=4

" jedi
  let g:jedi#popup_on_dot = 0
  let g:jedi#show_call_signatures = 0

" Quickfix shortcuts
  nnoremap <F11> :cprev <CR>
  nnoremap <F12> :cnext <CR>
