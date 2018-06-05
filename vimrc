set nocompatible              " be iMproved, required
filetype off                  " required
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'jlanzarotta/bufexplorer'
call vundle#end()            " required
filetype plugin indent on    " required

set ts=4
set sw=4
set et
set number
set hlsearch
set foldmethod=syntax
set nofoldenable

map <Tab> ]c
map <S-Tab> [c

map <F4> :call NextExt()<CR>
map <C-N> :NERDTreeToggle<CR>

set runtimepath^=~/.vim/bundle/ctrlp.vim

let g:grep_mode='auto'
let g:ext_groups = {'cpp':['c','h','cpp','hpp','inl'], 'cmake':['cmake','txt']}

map // "sy/<C-R>s<CR>
map gw "syiw/<C-R>s<CR>?<CR>:call SetGrep()<CR>:grep! '\<<cword>\>'<CR>:cw<CR>
map gt <C-P><C-\>w
map gs "sy/<C-R>s<CR>?<CR>:call SetGrep()<CR>:grep! "<C-R>s"<CR>:cw<CR>
map gg :call NextGrepMode()<CR>

"XXX: clean it
function! NextGrepMode()
    let gk = keys(g:ext_groups)
    call add(gk, 'auto')
    let gk += gk
    for k in gk
        if k==g:grep_mode
            let g:grep_mode=gk[index(gk,k)+1]
            echo g:grep_mode
            return
        endif
    endfor
endfunction

function! SetGrep()
    if g:grep_mode!='auto'
        execute('set grepprg=gred\ --ni\ --nc\ --'.g:grep_mode)
        return
    endif
    let ext = expand('%:e')
    let gk = keys(g:ext_groups)
    for k in gk
        let g=g:ext_groups[k]
        for e in g
            if e==ext
                execute('set grepprg=gred\ --ni\ --nc\ --'.k)
                return
            endif
        endfor
    endfor
    execute('set grepprg=gred\ --ni\ --nc')
endfunction

function! NextExt()
    let ext = expand('%:e')
    let name = expand('%:r')
    let gk = keys(g:ext_groups)
    for k in gk
        let g=g:ext_groups[k]
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

