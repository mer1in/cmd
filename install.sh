#!/bin/bash
git pull
VIMRC=~/.vimrc
OS=`uname -s`
if [ $OS = Darwin ]; then
    EXTENDED_REGEXP_KEY=E
    VRC_EXCLUDE='Conque-GDB ycm_server_python_interpreter'
    for dep in wget cmake; do [ -z "`which $dep`" ] && brew install $dep; done
    [ -f ~/.bashrc ] && sed -i '' '/#_V_UTILS_BEGIN_/,/#_V_UTILS_END_/d' ~/.bashrc
    for f in git-prompt.sh git-completion.bash ; do 
        [ -f ~/.$f ] || curl https://raw.githubusercontent.com/git/git/master/contrib/completion/$f -o ~/.$f
    done
else
    EXTENDED_REGEXP_KEY=r
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
fi
cat gred.src|sed "s/EXTENDED_REGEXP_KEY/$EXTENDED_REGEXP_KEY/" > gred
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
if [ $OS = Linux ]
then
    for f in .vimrc .bashrc .bashrc_prompt .tmux.conf
    do
        cat ./sync/ubuntu/$f > ~/$f
    done
fi
~/.v.utils/v --up

(cd ~/.vim/bundle/coc.nvim && yarn install)
