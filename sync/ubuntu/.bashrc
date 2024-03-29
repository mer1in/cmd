# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export EDITOR=/usr/bin/vim
#_V_UTILS_BEGIN_
[ -f ~/.bashrc_prompt ] && . ~/.bashrc_prompt

alias gred='~/.v.utils/gred'
alias svd='~/.v.utils/svd'
alias v='~/.v.utils/v'
alias vup='(H=~/.v.utils/src ; ([ -d $H ] || git clone https://github.com/mer1in/v $H) && cd $H && ./install.sh)'
alias gl="git log --graph --date=short --branches --pretty=format:'%C(yellow)%h%C(reset) %ad | %C(75)%s%C(reset) %C(yellow)%d%C(reset) [%an]'"
alias git-key='eval `ssh-agent -s` ; ssh-add'
alias lswd='[ -d ~/.cds ] && for a in `ls ~/.cds`; do echo "$a = `cat ~/.cds/$a`"; done'
for a in {a..z} ; do alias "sd$a=[ -d ~/.cds ] || mkdir ~/.cds ; pwd > ~/.cds/$a; echo \"$a: \`cat ~/.cds/$a;\`\"" ; done
for a in {a..z} ; do alias "cd$a=[[ -d ~/.cds && -f ~/.cds/$a ]] && cd \`cat ~/.cds/$a\` && pwd || echo '$a doesnt exist'" ; done
alias cdr='cd $(~/.v.utils/cdr)'
alias cdt='_TMP=/tmp/`genpass`; mkdir $_TMP; cd $_TMP'
alias cdswd='[ -d ~/.cds ] && d="`for a in $(ls ~/.cds/|grep -v config); do echo \"$a = $(cat ~/.cds/$a)\"; done|fzf +m -e`" && { [ -z "$d" ] || cd $(echo $d|sed "s/^. = //") ; }'
alias sdr='echo "r is reserved for git root"'
#bind '"\C-gd": "\C-ex\C-u cdswd\C-m\C-y\C-b\C-d"'

# wsl conf expected format: [ { "prefix": "/mnt/c", "drive": "c:" }, {...} ]
CF=~/.cds/config.json; [ -f $CF ] && export WINDOWS_PREFIXES=`cat $CF |jq -r '.[] | .prefix'`

alias gut=git
bind '"\C-gp": "\C-ex\C-u git push || \
    git pull -r && git push || \
    ! git rev-parse --abbrev-ref --symbolic-full-name @{u} && \
    git push --set-upstream origin `git branch --show-current`\C-m\C-y\C-b\C-d"'
#bind '"\C-gp": "\C-ex\C-u git push || git pull -r && git push\C-m\C-y\C-b\C-d"'
bind '"\C-gg": "\C-ex\C-u git remote update origin --prune ; git pull -r ;  git submodule update --init \C-m\C-y\C-b\C-d"'
function git_hist_file(){
    rev=$1
    PROMPT=$(git ll -1 --color=always $rev)
    while [ 1 ]
    do
        search=`git log --name-only --oneline -1 $rev | \
            sed -n '2,$p'| \
            fzf +m +1 --prompt="$PROMPT > " -q "$q" \
                --preview="git log --oneline -p -1 $rev -- {} | ydiff -s -w0 -c always" \
                --preview-window=down,70% --height=100% --print-query \
                --bind "ctrl-w:become(git difftool $rev^..$rev -- {} < /dev/tty > /dev/tty)"`
        [ -z "$search" ] || return
    done
}
function git_hist(){
    (
    OBJ=$1
    BRANCH=`git branch --show-current`
    [ -z $OBJ ] && OBJ=`git rev-parse --show-prefix`
    cdr
    while [ 1 ]
    do
        search=$(git ll --color=always -- $OBJ | \
            fzf -q "$query" --print-query +m --ansi --prompt="$OBJ @ $BRANCH > " \
            --header $'╱ (Enter) commit ╱ (W)rite hash ╱ chec(K)out ╱ (S)oft reset ╱ mi(X)ed reset \n\n' \
            --bind 'ctrl-w:become(echo HASH:{}|sed "s#^. = ##")' \
            --bind 'ctrl-k:execute:git co {1} ' \
            --bind 'ctrl-s:execute:git reset --soft {1} ' \
            --bind 'ctrl-x:execute:git reset --mixed {1} ' \
            --preview 'R=`echo {}|sed s"/ .*//"` ;\
                    git log -1 --name-status $R|batcat --color=always --style=plain ; \
                    echo ; git diff -U0  $R^..$R | batcat --color=always --style=numbers' --height=100)
        rev=$(echo "$search"|sed -n 2p|sed 's/ .*//')
        query=`echo "$search" | sed -n '1p'`
        [ -n "`echo $search|grep HASH`" ] && echo $search| \
            sed -e 's/HASH://' -e 's/ .*//' && return
        [ -z $rev ] && return
        git_hist_file $rev
    done
    )
}

git-history-widget-root(){
  local selected="$(git_hist `cdr;pwd`)"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

git-history-widget(){
  local selected="$(git_hist)"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

function git_cbr(){
    git branch -a --sort=-committerdate | sed -e 's/remotes\/origin\///' -e 's/^..//' | \
        grep -v HEAD | uniq | \
        fzf --header "Checkout Branch in `git remote get-url origin`" --preview "git show-branch {1} &>/dev/null && git ll {1} --color=always || git ll remotes/origin/{1} --color=always" | xargs git co
}
bind -m emacs-standard -x '"\C-gh": git-history-widget'
bind -m emacs-standard -x '"\C-gH": git-history-widget-root'
bind '"\C-gc": "\C-ex\C-u git_cbr\C-m\C-y\C-b\C-d"'
bind '"\C-g-": "\C-ex\C-u git co -\C-m\C-y\C-b\C-d"'
bind '"\C-gq": "\C-ex\C-u git merge --squash `git name-rev $(git rev-parse @{-1}) --name-only`\C-m\C-y\C-b\C-d"'
bind '"\C-gm": "\C-ex\C-u git merge --no-edit `git name-rev $(git rev-parse @{-1}) --name-only`\C-m\C-y\C-b\C-d"'
#_V_UTILS_END_

export FZF_DEFAULT_OPTS="--no-mouse --height 50% -1 --reverse --multi --inline-info --preview='[[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file || (PF={}; PF=\${PF/#\~/$HOME}; batcat --style=numbers --color=always \$PF) 2>/dev/null | head -300' --preview-window='right' --bind='f3:execute(PF={}; PF=\${PF/#\~/$HOME}; batcat --style=numbers \$PF),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo {+}|clip.exe)'"
alias l='ls -G'
alias ls='ls -G'
alias ll='ls -Gal'
alias cd..='cd ..'
alias cd-='cd -'

export EDITOR=vim
[ -f ~/.vim/bundle/fzf/shell/completion.bash ] && . ~/.vim/bundle/fzf/shell/completion.bash
[ -f ~/.vim/bundle/fzf/shell/key-bindings.bash ] && . ~/.vim/bundle/fzf/shell/key-bindings.bash
enter_ssh_host(){
    HOST=$1
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $HOST 'echo' &>/dev/null
    ERR=$?
    if (( $ERR == 255 ))
    then
        echo -n "${HOST}'s password:"
        ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $HOST &>/dev/null
    fi
    ssh -X -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $HOST
}

run_ssh(){
    S_SSH_HOSTS=~/.ssh-hosts
    [ -f $S_SSH_HOSTS ] || touch $S_SSH_HOSTS
    FZF_DEFAULT_OPTS="--no-mouse --height 50% -1 --reverse --multi --inline-info --bind='ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-y:execute-silent(echo {+}|clip.exe)'"
    SELECTION=`cat $S_SSH_HOSTS | grep -v '^ *#' | fzf --print-query +m \
        --bind 'ctrl-w:become(echo "#{}")' \
        --bind 'ctrl-h:become(echo {}|sed "s_.*@_#_")' \
        --header $'╱ Enter (ssh selection) ╱ (W)rite selection to command line / (H)ostname to command line \n\n'`
    [[ "${SELECTION:0:1}" == "#" ]] && echo ${SELECTION:1}|sed "s/'//g" && return 
    HOST=`echo $SELECTION|sed 's/.* //'`
    [ -n "$HOST" ] || return
    [ -z "`cat $S_SSH_HOSTS|grep $HOST`" ] && echo $HOST >> $S_SSH_HOSTS
    [ -n "$TMUX" ]  && \
        tmux new-window -n "ssh $HOST" ". ~/.bashrc 2>/dev/null ; enter_ssh_host $HOST" || \
        enter_ssh_host $HOST
}

bind '"\C-kk": kill-line'

alias k=kubectl
complete -o default -F __start_kubectl k
pods() {
  FZF_SVC_COMMAND="kubectl get svc -o wide --all-namespaces" \
  FZF_DEFAULT_COMMAND="kubectl get pods --all-namespaces" \
    fzf --info=inline --layout=reverse --header-lines=1 --height=100\
        --prompt "$(kubectl config current-context | sed 's/-context$//')> " \
        --header $'╱ Enter (exec) ╱ (L)og ╱ (P)rev logs ╱ (R)eload ╱ (D)escribe ╱ (E)dit ╱ (K)ill ╱ \n\n' \
        --bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
        --bind 'enter:execute:kubectl exec -it --namespace {1} {2} -- sh > /dev/tty' \
        --bind 'ctrl-l:execute:${EDITOR:-vim} <(kubectl logs --all-containers --namespace {1} {2}) > /dev/tty' \
        --bind 'ctrl-p:execute:${EDITOR:-vim} <(kubectl logs -p --namespace {1} {2}) > /dev/tty' \
        --bind 'ctrl-e:execute:EDITOR=vim kubectl edit --namespace {1} pod {2}' \
        --bind 'ctrl-k:execute:kubectl delete -n {1} pod {2}' \
        --bind 'ctrl-d:execute:batcat --paging=always <(kubectl describe --namespace {1} pod/{2}) > /dev/tty' \
        --bind 'ctrl-r:reload:$FZF_DEFAULT_COMMAND' \
        --bind 'ctrl-s:reload:$FZF_SVC_COMMAND' \
        --preview-window up:follow \
        --preview 'kubectl logs --follow --all-containers --tail=10000 --namespace {1} {2}' "$@"
}

bind '"\C-np": "\C-ex\C-u pods\C-m\C-y\C-b\C-d"'
bind '"\C-kn": "\C-ex\C-u pods\C-m\C-y\C-b\C-d"'
run_k9s() { /home/roman/src/k9s/execs/k9s; }
bind '"\C-kp": "\C-ex\C-u run_k9s\C-m\C-y\C-b\C-d"'
choose_kubeconfig(){
(
    cd ~/.kube/configs/
    for a in `ls` ; do diff $a ../config &>/dev/null && export CURR_CFG=$a ; done
    if [ -n "$CURR_CFG" ]
    then
        CURR_CTX=" `kubectl config get-contexts|grep '^*'|awk '{print $2}'` @$CURR_CFG > "
    fi
    NKC="`ls|fzf +m \
        --preview='kubectl config --kubeconfig={1} get-contexts' \
        --prompt "$CURR_CTX"`" 
    if [ -n "$NKC" ]
    then
        if (( `kubectl config --kubeconfig=$NKC get-contexts -o name | wc -l` > 1 ))
        then
            NKCTX="`kubectl config --kubeconfig=$NKC get-contexts | grep -v NAMESPACE | fzf +m --prompt $NKC \
                --preview-window left \
                --preview '. ~/.bashrc 2>/dev/null ; '\
'ls | awk -v fnam="'$NKC'" '"'"'{ if($1==fnam){ printf("%c[1;32m%s%c[1;0m\n", 27, $0, 27) } else { print } }'"'; "\
'C=$(echo {}|awk '"'"'{if($1=="*"){print $3}else{print $2}}'"')"'; '\
'A=$(cat '$NKC' | yq  .clusters -ojson | jq -c ".[] | select(.name | contains(\\"$C\\")).cluster.server"); echo "$C $A"'`"
            NKCTX="`echo "$NKCTX" | sed -e 's/^\**[[:space:]]*//' -e  's/[[:space:]].*//'`"
            [ -z $NKCTX ] && exit
            [[ "$NKCTX" == '*' ]] || kubectl config --kubeconfig=$NKC use-context $NKCTX
        fi
        cat $NKC > ~/.kube/config
    fi
) }
bind '"\C-nc": "\C-ex\C-u choose_kubeconfig\C-m\C-y\C-b\C-d"'
bind '"\C-kc": "\C-ex\C-u choose_kubeconfig\C-m\C-y\C-b\C-d"'

genpass(){
    local len=$1
    [ -z $len ] && len=12
    dd if=/dev/urandom count=1 2> /dev/null | uuencode -m - | sed -ne 2p | cut -c-$len
}
__fuck__(){
    local cmd='command python3 ~/.tf/stf.py $(history 1 | head -n 1 | cut -c 8-)'
	local opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse ${FZF_DEFAULT_OPTS-} ${FZF_CTRL_T_OPTS-} +m"
    #cmd='for a in "1 1" "2 2" "3 3"; do echo $a; done'
    #cmd='history | fzf +m'
	eval "$cmd" |
	  FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) "$@" |
	  while read -r item; do
		printf "$item"
	  done
}
fuck-widget(){
#(( $? )) || {selected=$() 
  local selected="$(__fuck__ "$@")"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}
__cdswd(){
    [ -d ~/.cds ] || return
    for a in $(ls ~/.cds/|grep -v config)
    do 
        echo "$a = $(cat ~/.cds/$a)"
    done|fzf +m -e \
        --bind 'ctrl-w:become(echo {}|sed "s#^. = ##")' \
        --preview='d=`echo {}|sed "s#^. = ##"`; \
            . ~/.bashrc 2>/dev/null ; \
            printf "${__GREY_ON_GREEN}`basename $d`${__RST}\n"; \
            gs=`cd $d; get_git_status clean-colors`; [ -n "$gs" ] \
                && printf "$gs${__RST}\n"; \
            echo; ls -l --color $d'  \
        --header $'╱ Enter (cd selection) ╱ (W)rite selection to command line \n\n'
}
cdswd-widget(){
  local selected="$(__cdswd "$@")"
  local cleaned="`echo $selected|sed 's/^. = //'`"
  # if selected starts with '. = ', enter was hit, otherwise it was ctrl+w
  if [[ $selected == $cleaned ]]
  then
      READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
      READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
  else
      cd $cleaned
      printf "${__GREY_ON_GREEN}`pwd`\n"
  fi
}
bind -m emacs-standard -x '"\C-gf": fuck-widget'
bind -m emacs-standard -x '"\C-gd": cdswd-widget'

__ssh__(){
    S_SSH_HOSTS=~/.ssh-hosts
    [ -f $S_SSH_HOSTS ] || touch $S_SSH_HOSTS
    FZF_DEFAULT_OPTS="--no-mouse --height 50% -1 --reverse --multi --inline-info --bind='ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-y:execute-silent(echo {+}|clip.exe)'"
    SELECTION=`cat $S_SSH_HOSTS | grep -v '^ *#' | fzf --print-query +m \
        --bind 'ctrl-w:become(echo "#{}")' \
        --header $'╱ Enter (ssh selection) ╱ (W)rite selection to command line \n\n'`
    [[ "${SELECTION:0:1}" == "#" ]] && echo ${SELECTION:1}|sed "s/'//g" && return 
    HOST=`echo $SELECTION|sed 's/.* //'`
    [ -n "$HOST" ] || return
    [ -z "`cat $S_SSH_HOSTS|grep $HOST`" ] && echo $HOST >> $S_SSH_HOSTS
    [ -n "$TMUX" ]  && \
        tmux new-window -n "ssh $HOST" ". ~/.bashrc 2>/dev/null ; enter_ssh_host $HOST" || \
        enter_ssh_host $HOST
}

ssh-widget(){
  local selected="$(run_ssh"$@")"
  echo "$selected"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}
bind -m emacs-standard -x '"\C-gs": ssh-widget'
bind -m emacs-standard -x '"\C-xa": tmux a || tmux'
bind -m emacs-standard -x '"\C-xr": . ~/.bashrc && echo "bashrc reloaded"'
#bind '"\C-gs": "\C-ex\C-u run_ssh\C-m\C-y\C-b\C-d"'

tabstyle(){
    [ -z $TMUX_PANE ] && return
#    window_index=`tmux list-panes -a -F '#{pane_id}#{window_id}' | grep "$TMUX_PANE" | sed -e "s/$TMUX_PANE//" -e 's/@//'`
#    [ -z $window_index ] && echo "Window index not determined"
    tmux set-window-option -t $TMUX_PANE window-status-style $1
    [ -z $2 ] || tmux rename-window -t $TMUX_PANE $2
}
taberr(){
    tabstyle bg=red,fg=black $1
}
tabok(){
    tabstyle bg=green,fg=black $1
}
tabrun(){
    tabstyle bg=black,fg=white $1
}
tabdefault(){
    tabstyle bg=default,fg=default $1
}
export TMUX_PREF=a
export -f taberr
export -f tabok
export -f tabrun
export -f tabdefault
export -f tabstyle

source <(helm completion bash)
source <(kubectl completion bash)
complete -C '/usr/local/bin/aws_completer' aws

export PATH=$PATH:/usr/local/go/bin

[ -f ~/.bashrc.local ] && . ~/.bashrc.local
