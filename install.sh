#!/bin/bash
git pull
VIMRC=~/.vimrc
OS=`uname -s`
if [ $OS = Darwin ]; then
    BATCAT=bat
    EXTENDED_REGEXP_KEY=E
    VRC_EXCLUDE='Conque-GDB ycm_server_python_interpreter'
    for dep in wget cmake; do [ -z "`which $dep`" ] && brew install $dep; done
    [ -f ~/.bashrc ] && sed -i '' '/#_V_UTILS_BEGIN_/,/#_V_UTILS_END_/d' ~/.bashrc
    for f in git-prompt.sh git-completion.bash ; do 
        [ -f ~/.$f ] || curl https://raw.githubusercontent.com/git/git/master/contrib/completion/$f -o ~/.$f
    done
else
    EXTENDED_REGEXP_KEY=r
    BATCAT=batcat
    VRC_EXCLUDE=XXXXXXX
    [ -f ~/.bashrc ] && sed -i '/#_V_UTILS_BEGIN_/,/#_V_UTILS_END_/d' ~/.bashrc
    curl -V > /dev/null || sudo apt-get install -y curl
    #install nodejs on Ubuntu
    node -v > /dev/null || { \
        curl -sL https://deb.nodesource.com/setup_16.x | sudo bash - ; \
        sudo apt-get -y update; \
        sudo apt-get install -y nodejs; \
    }
    npm -v || sudo apt -y install npm
    yarn -v || sudo npm install --global yarn
    fzf --version && [[ "`fzf --version|sed 's/ .*//'`" == "0.38.0" ]] || {
        sudo apt purge fzf -y
        (
            cd /tmp
            PKG=fzf_0.38.0-1_amd64.deb 
            wget http://security.ubuntu.com/ubuntu/pool/universe/f/fzf/$PKG
            sudo dpkg -i $PKG
            rm $PKG
        )
    }
    [ -d ~/.local/bin ] || mkdir -p ~/.local/bin
    cp sync/ubuntu/local/* ~/.local/bin/
fi
cat gred.src| \
    sed "s/EXTENDED_REGEXP_KEY/$EXTENDED_REGEXP_KEY/" |\
    sed "s/BATCAT/$BATCAT/" > gred
mkdir -p ~/.v.utils/tmp 2>/dev/null
for a in v gred svd cdr; do cp $a ~/.v.utils/; chmod +x ~/.v.utils/$a; done
(
    git clone https://github.com/altercation/vim-colors-solarized.git
    mkdir -p ~/.vim/colors/
    cp ./vim-colors-solarized/colors/solarized.vim ~/.vim/colors/
)
rm gred
cp vimrc vimrc.tmp
for e in $VRC_EXCLUDE ; do
    cat vimrc.tmp|grep -v $e > $VIMRC
    cat $VIMRC > vimrc.tmp
done
rm vimrc.tmp
cat <<"EOM" >>~/.bashrc
#_V_UTILS_BEGIN_
[ -f ~/.bashrc_prompt ] && . ~/.bashrc_prompt

alias gred='~/.v.utils/gred'
alias svd='~/.v.utils/svd'
alias v='~/.v.utils/v'
alias vup='(H=~/.v.utils/src ; ([ -d $H ] || git clone https://github.com/mer1in/v $H) && cd $H && ./install.sh)'
alias gl="git log --graph --date=short --branches --pretty=format:'%C(yellow)%h%C(reset) %ad | %C(75)%s%C(reset) %C(yellow)%d%C(reset) [%an]'"
alias lswd='[ -d ~/.cds ] && for a in `ls ~/.cds`; do echo "$a = `cat ~/.cds/$a`"; done'
for a in {a..z} ; do alias "scwd$a=[ -d ~/.cds ] || mkdir ~/.cds ; pwd > ~/.cds/$a" ; done
for a in {a..z} ; do alias "cd$a=[[ -d ~/.cds && -f ~/.cds/$a ]] && cd \`cat ~/.cds/$a\` || echo '$a doesnt exist'" ; done
alias cdr='cd $(~/.v.utils/cdr)'
alias cdl='[ -d ~/.cds ] && d="`for a in $(ls ~/.cds/); do echo \"$a = $(cat ~/.cds/$a)\"; done|fzf +m -e`" && { [ -z "$d" ] || cd $(echo $d|sed "s/^. = //") ; }'
alias scwdr='echo ERR'
bind -m emacs-standard '"\C-g": "cdl\C-m"'
alias gut=git
export FZF_DEFAULT_OPTS="--no-mouse --height 50% -1 --reverse --multi --inline-info --preview='[[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file || (PF={}; PF=\${PF/#\~/$HOME}; bat --style=numbers --color=always \$PF) 2>/dev/null | head -300' --preview-window='right' --bind='f3:execute(PF={}; PF=\${PF/#\~/$HOME}; bat --style=numbers \$PF),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo {+}|pbcopy)'"
#_V_UTILS_END_
EOM
cp ./bashrc_prompt ~/.bashrc_prompt

git config --global alias.co checkout
git config --global alias.s status
git config --global alias.br "branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate"
git config --global alias.ll '!git log --pretty=format:"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) [%an]" --abbrev-commit'
git config --global alias.lg '!git log --oneline --decorate --graph'

git config --global diff.tool vimdiff
git config --global merge.tool vimdiff
git config --global difftool.prompt false

if [ $OS = Linux ]
then
    for f in .vimrc .bashrc .bashrc_prompt .tmux.conf
    do
        cat ./sync/ubuntu/$f > ~/$f
    done

    kubectl version || {
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl
        sudo apt-get install -y apt-transport-https
        curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
        echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
        sudo apt-get update
        sudo apt-get install -y kubectl
    }
    batcat --version || sudo apt -y install bat
    jq --version || sudo apt -y install jq
    yq --version || (
        cd /tmp
        VERSION=v4.33.3
        BINARY=yq_linux_amd64
        wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz
        tar xzf ${BINARY}.tar.gz
        sudo mv ${BINARY} /usr/bin/yq
        sudo ln -s /usr/bin/yq /usr/local/bin/yq
    )
fi
~/.v.utils/v --up

(cd ~/.vim/bundle/coc.nvim && yarn install)
