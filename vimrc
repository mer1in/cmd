syntax on
set nocompatible              " be iMproved, required
filetype off                  " required
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'Conque-GDB'
call vundle#end()            " required
filetype plugin indent on    " required

set ts=4
set sw=4
set et
set number
set hlsearch
set foldmethod=syntax
set nofoldenable

map <Leader>e :%s/\<<C-R><C-w>\>/<C-R>"/g<CR>

map <Tab> ]c
map <S-Tab> [c

map <F4> :call NextExt()<CR>
map <C-N> :NERDTreeToggle<CR>

set runtimepath^=~/.vim/bundle/ctrlp.vim

let g:grep_mode='auto'
let g:ext_groups = {'cpp': ['c','h','cpp','hpp','inl','cu'], 'cmake': ['cmake','txt'], 'py': ['py']}

map // "sy/<C-R>s<CR>
map gw "syiw/<C-R>s<CR>?<CR>:call SetGrep()<CR>:grep! '\<<cword>\>'<CR>:cw<CR>
map gt <C-P><C-\>w
map gs "sy/<C-R>s<CR>?<CR>:call SetGrep()<CR>:grep! "<C-R>s"<CR>:cw<CR>
map gb :call SetGrep()<CR>:grep! "<C-R>/"<CR>:cw<CR>
map gm :call NextGrepMode()<CR>

"XXX: clean it
function! NextGrepMode()
    let gk = keys(g:ext_groups)
    call add(gk, 'auto')
    call add(gk, 'none')
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
    let gred_exec = $HOME.'/.v.utils/gred\ --ni\ --nc'
    if g:grep_mode=='none'
        execute('set grepprg='.gred_exec.'\ --nox')
        return
    endif
    if g:grep_mode!='auto'
        execute('set grepprg='.gred_exec.'\ --'.g:grep_mode)
        return
    endif
    let ext = expand('%:e')
    let gk = keys(g:ext_groups)
    for k in gk
        let g=g:ext_groups[k]
        for e in g
            if e==ext
                execute('set grepprg='.gred_exec.'\ --'.k)
                return
            endif
        endfor
    endfor
    execute('set grepprg='.gred_exec)
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

map <F5> :execute('ConqueGdb --args '.MkRunCmd(g:run_cmd))<CR>b *main<CR>run<CR>
map <Leader>k :call Background()<CR>
nmap <Leader>h :brow old<CR>

set laststatus=2
set background=dark

let s:sel = 0
let g:run_cmd = ''
let g:build_modes = ['Release','Release_Internal','Debug']
let g:build_mode = 'Release_Internal'

function! NextBuildMode()
    let gk = g:build_modes
    let gk += gk
    for k in gk
        if k==g:build_mode
            let g:build_mode=gk[index(gk,k)+1]
            echo g:build_mode
            return
        endif
    endfor
endfunction

function! Background()
    let g:current_background = get(g:, 'current_background', 'light')
    if 'light'==g:current_background
        let g:current_background = 'dark'
    else
        let g:current_background = 'light'
    endif
    exec(':set background='.g:current_background)
endfunction

function! Compile(conf, build, run, ...)
    let m = g:build_mode
    let c = ''
    let s = '======================== '.g:build_mode.' ========================'
    let cmd = '![ -d logs ] || mkdir logs; BDIR=build/'.g:build_mode.'; mkdir -p $BDIR 2>/dev/null; '
    let hint = m . ' : '
    if a:conf
        let cmd .= '(t=`date`; '
        let r = '(cd $BDIR; cmake -DCMAKE_BUILD_TYPE='.m.' ../../ ; echo "exit with $?") 2>&1|tee logs/conf.'.m
        let cmd .= r.' ;(echo "'.s.'"; echo "'.r.'"; echo "Started  @$t"; echo "Finished @`date`") >>logs/conf.'.m.')'
        let hint .= ' conf '
        let c = ' && '
    endif
    if a:build
        let cmd .= c.'(t=`date`; '
        let r = '(cd $BDIR; cmake --build . -- -j20; echo "exit with $?") 2>&1|tee logs/build.'.m
        let cmd .= r.' ;(echo "'.s.'"; echo "'.r.'"; echo "Started  @$t"; echo "Finished @`date`") >>logs/build.'.m.')'
        let hint .= ' build '
        let c = ' && '
    endif
    if a:run
        let cmd .= c.'(t=`date`; '
        let r = '('.MkRunCmd(g:run_cmd).' 2>&1 ; echo "exit with $?")|tee logs/run.'.m
        let cmd .= r.' ; (echo "'.s.'"; echo '''.r.'''; echo "Started  @$t"; echo "Finished @`date`") >>logs/run.'.m.')'
        let hint .= ' run '
    endif
    echo hint . ' (' . a:conf . a:build . a:run . ')'
    let cmd .= '; echo "'.hint.'"'
    execute(cmd)
    if a:conf
       execute('e logs/conf.'.m)
    endif
    if a:build
       execute('e logs/build.'.m)
    endif
    if a:run && filereadable('logs/run.'.m)
       execute('e logs/run.'.m)
    endif
endfunction

function! MkRunCmd(str)
    return substitute(a:str, '%BUILD_MODE%', g:build_mode, "g")
endfunction

function! ShowMenu()
    let s:run_cmd = g:run_cmd
    let done = 0
    while !done
        let done = !ShowConf(1)
    endwhile
endfunction

function! ShowConf(r)
    redraw!
    echohl MoreMsg
    echo "ctrl+n = nerdtree | ctrl+p = file open | \\be = buff explorer | <F4> = .cpp->.hpp->..."
    echo "\\e = subst word with buffer | \\k = dark/light | \\h = history | // = search selection"
    echo "grep: gw = word | gs = selection | gb = buffer | gm = mode | gt = ctrlp word @cursor"
    echo "ccbr : c+[c]onfig+[b]uild+[r]un | cD : rm %BUILD_MODE% | <F5> : start debug"
    echohl None
    echo "====================="
    echo "Current settings are:"
    echo "====================="
    echo "Build [m]ode : "
    echohl QuickFixLine
    echon g:build_mode
    echohl None
    echo "Run/debug command : "
    echohl QuickFixLine
    echon MkRunCmd(s:run_cmd)
    echohl None
    echo "[e]dit list below"
    if !a:r
        return 0
    endif
    let s:ftd = get(s:, 'ftd', []) 
    if filereadable($HOME."/.vimrc_run_cmds")
        let lst = filter(copy(readfile($HOME."/.vimrc_run_cmds")), 'v:val!~"^$"')
        let s:ftd = filter(copy(lst), 'v:val!~"^\[ \]*#"')
    else
        let c = ["# Put your test commands here and choose one later with `cx`", "#"]
        let c = c + ["# %BUILD_MODE% - substituted with current build mode", "#"]
        if (writefile(c, $HOME."/.vimrc_run_cmds"))
            echo "error writing ".$HOME."/.vimrc_run_cmds"
        endif
    endif
    call ShowChoice(s:ftd)
    return HandleKey(s:ftd)
endfunction

function! ShowChoice(l)
    let idx = 0 
    for line in a:l 
        let p = ' ' 
        if idx==s:sel
           let p = '>' 
           echohl Underlined
        endif
        echo p." ".line
        echohl None
        let idx += 1
    endfor
endfunction

function! HandleKey(lst)
    let key = getchar()
    if nr2char(key)==nr2char(27)
        return 0
    endif
    if len(a:lst)
        if key == "\<Up>"
            let s:sel = s:sel==0 ? 0 : s:sel-1
            let s:run_cmd = a:lst[s:sel]
        endif
        if key == "\<Down>"
            let s:sel = s:sel<len(a:lst)-1 ? s:sel+1 : s:sel
            let s:run_cmd = a:lst[s:sel]
        endif
        if key == 13 || key == 10
            let g:run_cmd = a:lst[s:sel]
            return 0
        endif
    endif
    if nr2char(key) == "m"
        call NextBuildMode()
    endif
    if nr2char(key) == "e"
        execute('e '.$HOME.'/.vimrc_run_cmds')
        return 0
    endif
    return 1
endfunction

map cm :call NextBuildMode()<CR>
map cc :call Compile(1,0,0)<CR>
map ccb :call Compile(1,1,0)<CR>/\c\<error\><CR>
map ccbr :call Compile(1,1,1)<CR>
map cb :call Compile(0,1,0)<CR>/\c\<error\><CR>
map cbr :call Compile(0,1,1)<CR>
map cr :call Compile(0,0,1)<CR>
map cD :execute(':!rm -fr build/'.g:build_mode)<CR>
map cx :call ShowMenu()<CR>

if &diff
    syntax off
    colorscheme evening
endif
"XXX use @linux only
"let g:NERDTreeDirArrowExpandable = '+'
"let g:NERDTreeDirArrowCollapsible = 'v'
