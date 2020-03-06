#!/bin/bash

set -e

ARCH=`arch`
PKG=`basename $0`

apt-get update
apt-get install -y cabal-install

echo "I am `whoami`, I will build $ARCH-$PKG"
echo "cabal init"
cabal user-config init -v

echo "v2-update"
cabal v2-update -v

echo "v2-install $PKG"
cabal v2-install $PKG -v


tar zcvf $ARCH-$PKG.tar.gz /root/.cabal/store/ghc-8.6.5/

echo "Finish $ARCH-$PKG.tar.gz"
