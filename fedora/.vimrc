set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set guicursor+=a:blinkon0
set noswapfile
set vb t_vb=
colorscheme ron

set nocompatible
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin('~/.vim/vundle')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" plugins managed by vundle
Plugin 'fatih/vim-go'
Plugin 'ctrlp.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-colorscheme-switcher'

call vundle#end()            " required
filetype plugin indent on    " required

" powerline variants of fonts are required for airline, they need to be
" installed separately
let g:airline_powerline_fonts = 1

