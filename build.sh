#!/bin/bash

set -e

[ $# -lt 1 ] && echo "$0 pkg" && exit 1

ARCH=`arch`

apt-get update
apt-get install -y cabal-install

function release() {
	mv $BINDIR/$1 $BINDIR/$1-$2-$ARCH
	xz $BINDIR/$1-$2-$ARCH
}

cabal user-config init
cabal v2-update
cabal v2-install $1


tar zcvf $ARCH-$1.tar.gz /root/.cabal/store/ghc-8.6.5/
