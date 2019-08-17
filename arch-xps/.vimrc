"let mapleader = ','

call plug#begin('~/.vim/plugged')

Plug 'https://github.com/scrooloose/nerdtree.git'
Plug 'git://github.com/altercation/vim-colors-solarized.git'
Plug 'https://github.com/xolox/vim-misc.git'
Plug 'NLKNguyen/papercolor-theme'
Plug 'https://github.com/reedes/vim-colors-pencil.git'
Plug 'https://github.com/mswift42/vim-themes.git'
Plug 'https://github.com/xolox/vim-colorscheme-switcher.git'

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
"  set t_Co=256
  set background=light
  " colorscheme soft-morning
  colorscheme catz
  if has("gui_running")
    set termguicolors
    set guifont=Inconsolata\ 13
    set guioptions-=L  "remove left-hand scroll bar
  endif

" Highlight search and use C-l to disable highlighting until the next search
"  set hlsearch
"  nnoremap <leader>l :noh<CR><C-l>

" Open new split in the correct direction
  set splitbelow splitright

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
  vnoremap <leader>y "*y
  vnoremap <leader>d "*d
  nnoremap <leader>p "*p

" Experimental stuff " Use <F11> to toggle between paste and nopaste set pastetoggle=<F11>

" Nerd tree
	map <leader>n :NERDTreeToggle<CR>
	autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") &&
    \ b:NERDTree.isTabTree()) | q | endif

" When there is no filetype-specific indenting enabled,
" keep the same indent as the current line
"  set autoindent

" Disable the autoindent
  filetype indent off

" gvim stuff
  set guioptions-=m  "menu bar
  set guioptions-=T  "toolbar
  set guioptions-=r  "scrollbar
