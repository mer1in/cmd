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

map <F4> :call NextExt()<CR>
map <C-N> :NERDTreeToggle<CR>

set runtimepath^=~/.vim/bundle/ctrlp.vim

set grepprg=gred\ -x\ Build\ -x\ ExternalLibs\ -x\ BcCaffe\ -cpp\ --ni\ --nc
map // "sy/<C-R>s<CR>
nnoremap gw :grep! '\<<cword>\>'<CR>:cw<CR>
map gt <C-P><C-\>w
map /g "sy:grep! "<C-R>s"<CR>:cw<CR>

function! NextExt()
    "XXX: import group from g:, use default if not set
    let groups = {'c++':['c','h','cpp','hpp','inl'], 'cmake':['cmake','txt']}
    let ext = expand('%:e')
    let name = expand('%:r')
    let gk = keys(groups)
    for k in gk
        let g=groups[k]
        for e in g
            if e==ext
                let sg = g[index(g,e)+1:]+g
                for ne in sg
                    if filereadable(name.".".ne)
                        execute("edit ".name.'.'.ne)
                        return
                    endif
                endfor
            endif
        endfor
    endfor
endfunction

