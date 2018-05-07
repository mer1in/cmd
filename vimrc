set nocompatible              " be iMproved, required
filetype off                  " required
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
call vundle#end()            " required
filetype plugin indent on    " required

set ts=4
set sw=4
set et
set number
set hlsearch
colo blue
set foldmethod=syntax
set nofoldenable

map <Tab> ]c
map <S-Tab> [c

"XXX: make cyclic with single key
map <F4> :e %<.cpp<CR>
map <F5> :e %<.h<CR>
map <F6> :e %<.c<CR>

map <C-N> :NERDTreeToggle<CR>

set runtimepath^=~/.vim/bundle/ctrlp.vim

set grepprg=gred\ -x\ Build\ -x\ ExternalLibs\ -x\ BcCaffe\ -cpp\ --ni\ --nc
map // "sy/<C-R>s<CR>
nnoremap gw :grep! '\<<cword>\>'<CR>:cw<CR>
map gt <C-P><C-\>w
map /g "sy:grep! "<C-R>s"<CR>:cw<CR>
