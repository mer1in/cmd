#!/bin/bash
let IS_ROOT=!`id -u`
git pull
if [ `uname -s` = Darwin ]; then
    (( $IS_ROOT )) || VIMRC=~/.vimrc
    EXTENDED_REGEXP_KEY=E
else
    if (( $IS_ROOT )); then
        VIMRC=/etc/vim/vimrc.local
    fi
    if [[ -f /etc/screenrc && -z "`cat /etc/screenrc|grep '^escape ^..'`" ]]; then
        echo 'escape ^Jj' >> /etc/screenrc
        echo "ATTENTION! The screen escape is redefined to '^Jj' @/etc/screenrc"
    fi
    EXTENDED_REGEXP_KEY=r
fi
cat gred.src|sed "s/EXTENDED_REGEXP_KEY/$EXTENDED_REGEXP_KEY/" > gred
(( $IS_ROOT )) && (DEST=/usr/local/bin; for a in v gred svd; do cp $a $DEST; chmod +x $DEST/$a; done)
rm gred
[ -n "$VIMRC" ] && cat vimrc > $VIMRC
v --up
