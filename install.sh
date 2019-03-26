#!/bin/bash
git pull
VIMRC=~/.vimrc
OS=`uname -s`
if [ $OS = Darwin ]; then
    EXTENDED_REGEXP_KEY=E
    VRC_EXCLUDE='Conque-GDB'
    [ -z "`which wget`" ] && brew install wget
    [ -f ~/.bashrc ] && sed -i '' '/#_V_UTILS_BEGIN_/,/#_V_UTILS_END_/d' ~/.bashrc
else
    EXTENDED_REGEXP_KEY=r
    VRC_EXCLUDE=XXXXXXX
    [ -f ~/.bashrc ] && sed -i '/#_V_UTILS_BEGIN_/,/#_V_UTILS_END_/d' ~/.bashrc
fi
cat gred.src|sed "s/EXTENDED_REGEXP_KEY/$EXTENDED_REGEXP_KEY/" > gred
mkdir -p ~/.v.utils/tmp 2>/dev/null
for a in v gred svd cdr; do cp $a ~/.v.utils/; chmod +x ~/.v.utils/$a; done
rm gred
cp vimrc vimrc.tmp
for e in $VRC_EXCLUDE ; do
    cat vimrc.tmp|grep -v $e > $VIMRC
    cat $VIMRC > vimrc.tmp
done
rm vimrc.tmp
cat <<EOM >>~/.bashrc
#_V_UTILS_BEGIN_
alias cdr='cd \$(~/.v.utils/cdr)'
alias gred='~/.v.utils/gred'
alias svd='~/.v.utils/svd'
alias v='~/.v.utils/v'
alias vup='(H=~/.v.utils/src ; ([ -d \$H ] || git clone https://github.com/mer1in/v \$H) && cd \$H && ./install.sh)'
#_V_UTILS_END_
EOM
~/.v.utils/v --up

if [ $OS = Darwin ] && [ ! -f ~/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party/clang/lib/libclang.dylib ]; then
    cd ~/.v.utils/tmp
    wget http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-apple-darwin.tar.xz
    tar xf clang+llvm-8.0.0-x86_64-apple-darwin.tar.xz
    mv clang+llvm-8.0.0-x86_64-apple-darwin clang
    cmake -G "Unix Makefiles" -DPATH_TO_LLVM_ROOT=~/.v.utils/tmp/clang . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp
    cmake --build . --target ycm_core
    rm -fr ~/.v.utils/tmp/* 2>/dev/null
fi
