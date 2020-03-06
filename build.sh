#!/bin/bash

set -e

ARCH=`arch`
PKG=`basename $0`

apt-get update
apt-get install -y cabal-install

echo "I am `whoami`, I will build $ARCH-$PKG"
echo "cabal init"
cabal user-config init

echo "v2-update"
cabal v2-update

echo "v2-install $PKG"
mkdir -p /home/runner/.cabal/store/ghc-8.6.5/package.db
cabal v2-install -v $PKG


tar zcvf $ARCH-$PKG.tar.gz /home/runner/.cabal/store/ghc-8.6.5/

echo "Finish $ARCH-$PKG.tar.gz"
ls -l
