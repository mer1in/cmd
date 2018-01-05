#!/bin/bash
git up
DEST=/usr/local/bin; for a in v gred svd; do cp $a $DEST; chmod +x $DEST/$a; done
