cmd line tools
==============

v
-
open file my-file @line 122
> `$ my-file:122:`

gred 
----
grep and edit
> `$ gred sed`

```
1:./gred:25:    tee >(cat|sed '='|sed 'N;s/\n/:/'|tee >((cat|sed 's/$/\n/') 1>&5) 1>&4)|\
2:./gred:26:    (sed -e 's,\x1B\[[0-9;]*[a-zA-Z],,g' -e 's,:.*,,'|sort -u)`" 
3:./gred:33:    [ $I = "`echo $line|sed 's/:.*//'`" ] &&\
4:./gred:34:        STRIPPED=`echo $line|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"` &&\
5:./gred:35:        LINE_NUM="`echo $STRIPPED|sed 's/^[^:]*:[^:]*://;s/:.*//'`" &&\
6:./gred:36:        EF=`echo $STRIPPED|sed -e 's/^[^:]*://;s/:.*//'` &&\
       1 files found
```
> `3`
opens file gred on line 33 with word `sed` in search buffer

svd
---
simplify svn diff:
```
svd [-c|-l|-a|-r]
no params - list of changed files
-l - list of changed files with status
-c - colordiff all changes
<filename> - vimdiff changed file
-a - vimdiff all changed files
-r - revert all changes
```

install.sh
----------
update && cp into `/usr/local/bin/`
