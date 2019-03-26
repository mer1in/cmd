#!/bin/bash
git pull
VIMRC=~/.vimrc
OS=`uname -s`
if [ $OS = Darwin ]; then
    EXTENDED_REGEXP_KEY=E
    VRC_EXCLUDE='Conque-GDB ycm_server_python_interpreter'
    for dep in wget cmake; do [ -z "`which $dep`" ] && brew install $dep; done
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

if [ $OS = Darwin ]; then
    YCM_LIBFILE=~/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party/clang/lib/libclang.dylib
    YCM_ARCHIVE=clang+llvm-8.0.0-x86_64-apple-darwin
else
    YCM_LIBFILE=~/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party/clang/lib/libclang.so.8
    YCM_ARCHIVE=clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-`lsb_release -a|grep Release|awk '{print $2}' 2>/dev/null`
fi

if [ ! -f $YCM_LIBFILE ]; then
    cd ~/.v.utils/tmp
    wget http://releases.llvm.org/8.0.0/$YCM_ARCHIVE.tar.xz
    tar xf $YCM_ARCHIVE.tar.xz
    mv $YCM_ARCHIVE clang
    cmake -G "Unix Makefiles" -DPATH_TO_LLVM_ROOT=~/.v.utils/tmp/clang . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp
    cmake --build . --target ycm_core
    rm -fr ~/.v.utils/tmp/* 2>/dev/null
fi
(cd ~/.vim/bundle/YouCompleteMe/third_party/ycmd; [ -d third_party/tsserver/lib/node_modules ] || npm install -g --prefix third_party/tsserver typescript)
