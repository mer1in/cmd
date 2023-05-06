# Fig pre block. Keep at the top of this file.
##_V_UTILS_BEGIN_
[ -f ~/.bashrc_prompt ] && . ~/.bashrc_prompt

alias gred='~/.v.utils/gred'
alias svd='~/.v.utils/svd'
alias v='~/.v.utils/v'
alias vup='(H=~/.v.utils/src ; ([ -d $H ] || git clone https://github.com/mer1in/v $H) && cd $H && ./install.sh)'
alias gl="git log --graph --date=short --branches --pretty=format:'%C(yellow)%h%C(reset) %ad | %C(75)%s%C(reset) %C(yellow)%d%C(reset) [%an]'"
alias lswd='[ -d ~/.cds ] && for a in `ls ~/.cds`; do echo "$a = `cat ~/.cds/$a`"; done'
for a in {a..z} ; do alias "scwd$a=[ -d ~/.cds ] || mkdir ~/.cds ; pwd > ~/.cds/$a" ; done
for a in {a..z} ; do alias "cd$a=[[ -d ~/.cds && -f ~/.cds/$a ]] && cd \`cat ~/.cds/$a\` || echo '$a doesnt exist'" ; done
for a in {a..z} ; do alias "shd$a=[[ -d ~/.cds && -f ~/.cds/$a ]] && cat ~/.cds/$a || echo '$a doesnt exist'" ; done
alias cdr='cd $(~/.v.utils/cdr)'
alias cdswd='[ -d ~/.cds ] && d="`for a in $(ls ~/.cds/); do echo \"$a = $(cat ~/.cds/$a)\"; done|fzf +m -e`" && { [ -z "$d" ] || cd $(echo $d|sed "s/^. = //") ; }'
alias cdswD='[ -d ~/.cds ] && d="`for a in $(ls ~/.cds/); do echo \"$a = $(cat ~/.cds/$a)\"; done|fzf +m -e`" && echo $d|sed "s/^. = //"'
alias scwdr='echo ERR'
bind '"\C-gd": "\C-ex\C-u cdswd\C-m\C-y\C-b\C-d"'
bind -m emacs-standard '"\C-gD": " \C-b\C-k \C-u`cdswD`\e\C-e\er\C-a\C-y\C-h\C-e\e\C-y\ey\C-x\C-x\C-f"'
alias gut=git
bind '"\C-gp": "\C-ex\C-u git push || git pull -r && git push\C-m\C-y\C-b\C-d"'
bind '"\C-gg": "\C-ex\C-u git pull -r\C-m\C-y\C-b\C-d"'
function git_hist_file(){
    rev=$1
    PROMPT=$(git ll -1 --color=always $rev)
    while [ 1 ]
    do
        search=`git log --name-only --oneline -1 $rev | sed -n '2,$p'|fzf +m +1 --prompt="$PROMPT > " -q "$q" --preview="git log --oneline -p -1 $rev -- {} | ydiff -s -w0 -c always" --preview-window=down,70% --height=100% --print-query`
        q="`echo "$search" | sed -n '1p'`"
        f="`echo "$search" | sed -n '2p'`"
        [ -z $f ] && return
        git difftool $rev^..$rev -- $f
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
        search=$(git ll --color=always -- $OBJ | fzf -q "$query" --print-query +m --ansi --prompt="$OBJ @ $BRANCH > "\
            --preview 'R=`echo {}|sed s"/ .*//"` ; git log -1 --name-status $R|bat --color=always --style=plain ; echo ; git diff -U0  $R^..$R | bat --color=always --style=numbers' --height=100)
        rev=$(echo "$search"|sed -n 2p|sed 's/ .*//')
        query=`echo "$search" | sed -n '1p'`
        [ -z $rev ] && return
        git_hist_file $rev
    done
    )
}
function git_cbr(){
    git branch -a --sort=-committerdate | sed -e 's/remotes\/origin\///' -e 's/^..//' | \
        grep -v HEAD | uniq | \
        fzf --header "Checkout Branch in `git remote get-url origin`" --preview "git show-branch {1} &>/dev/null && git ll {1} --color=always || git ll remotes/origin/{1} --color=always" | xargs git co
}
bind '"\C-gh": "\C-ex\C-u git_hist\C-m\C-y\C-b\C-d"'
bind '"\C-gc": "\C-ex\C-u git_cbr\C-m\C-y\C-b\C-d"'
bind '"\C-g-": "\C-ex\C-u git co -\C-m\C-y\C-b\C-d"'
bind '"\C-gm": "\C-ex\C-u git merge --squash `git name-rev $(git rev-parse @{-1}) --name-only`\C-m\C-y\C-b\C-d"'
#_V_UTILS_END_
. ~/completion.bash
. ~/key-bindings.bash
export FZF_DEFAULT_OPTS="--no-mouse --height 50% -1 --reverse --multi --inline-info --preview='[[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file || (PF={}; PF=\${PF/#\~/$HOME}; bat --style=numbers --color=always \$PF) 2>/dev/null | head -300' --preview-window='right' --bind='f3:execute(PF={}; PF=\${PF/#\~/$HOME}; bat --style=numbers \$PF),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo {+}|pbcopy)'"
alias l='ls -G'
alias ls='ls -G'
alias ll='ls -Gal'
export PATH=$PATH:~/Library/Python/3.9/bin
export PATH=$PATH:~/.local/bin
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
alias mm='[ -f .connection ] && sh .connection || echo "No connection settings found here"'
alias umm='(cd ~/shares && find . -type d -xdev | xargs umount 2>/dev/null)'


export GITLAB_HOME=$HOME/universe/volumes/gitlab
export JENKINS_HOME=$HOME/universe/volumes/jenkins

. /usr/local/Cellar/docker/20.10.17/etc/bash_completion.d/docker
. /usr/local/Cellar/kubernetes-cli/1.24.3/etc/bash_completion.d/kubectl
#complete -p kubectl
complete -o default -o nospace -F __start_kubectl k

alias mr='~/.v.utils/watcher.sh'
alias cd..='cd ..'
alias cd-='cd -'

export EDITOR=vim

function run_ssh(){
    S_SSH_HOSTS=~/.ssh-hosts
    [ -f $S_SSH_HOSTS ] || touch $S_SSH_HOSTS
    SELECTION=`cat $S_SSH_HOSTS | fzf --print-query +m`
    HOST=`echo $SELECTION|sed 's/.* //'`
    [ -n "$HOST" ] || return
    [ -z `cat $S_SSH_HOSTS|grep $HOST` ] && echo $HOST >> $S_SSH_HOSTS
    [ -n "$TMUX" ]  && \
        tmux new-window -n "ssh $HOST" "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $HOST" || \
        ssh -Y -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $HOST
}
bind '"\C-ns": "\C-ex\C-u run_ssh\C-m\C-y\C-b\C-d"'
bind '"\C-gs": "\C-ex\C-u run_ssh\C-m\C-y\C-b\C-d"'
alias r='python3 ~/GuestOSShared/sources/ranger/ranger.py'

# kuberNNNetes
alias k=kubectl
pods() {
  FZF_SVC_COMMAND="kubectl get svc -o wide --all-namespaces" \
  FZF_DEFAULT_COMMAND="kubectl get pods --all-namespaces" \
    fzf --info=inline --layout=reverse --header-lines=1 --height=100\
        --prompt "$(kubectl config current-context | sed 's/-context$//')> " \
        --header $'╱ Enter (kubectl exec) ╱ CTRL-O (open log in editor) ╱ CTRL-R (reload) ╱ CTRL-D (describe) /\n\n' \
        --bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
        --bind 'enter:execute:kubectl exec -it --namespace {1} {2} -- bash > /dev/tty' \
        --bind 'ctrl-o:execute:${EDITOR:-vim} <(kubectl logs --all-containers --namespace {1} {2}) > /dev/tty' \
        --bind 'ctrl-d:execute:bat --paging=always <(kubectl describe --namespace {1} pod/{2}) > /dev/tty' \
        --bind 'ctrl-r:reload:$FZF_DEFAULT_COMMAND' \
        --bind 'ctrl-s:reload:$FZF_SVC_COMMAND' \
        --preview-window up:follow \
        --preview 'kubectl logs --follow --all-containers --tail=10000 --namespace {1} {2}' "$@"
}

bind '"\C-np": "\C-ex\C-u pods\C-m\C-y\C-b\C-d"'
alias choose_kubeconfig=$'NKC="`cd ~/.kube/configs/ ; ls|fzf +m --preview=\'echo Current selection is $(echo $KUBECONFIG|sed s_.*\/__)\'`" ; [ -n "$NKC" ] && export KUBECONFIG=~/.kube/configs/$NKC && cat $KUBECONFIG>~/.kube/config'
bind '"\C-nc": "\C-ex\C-u choose_kubeconfig\C-m\C-y\C-b\C-d"'

alias a='argocd --port-forward-namespace argocd '
alias argostart='open "https://localhost:8080/applications" ; kubectl port-forward svc/argocd-server -n argocd 8080:8080'
alias longhornstart='open "http://localhost:8081" ; kubectl port-forward -n longhorn-system svc/longhorn-frontend 8081:80'
alias j=~/j
