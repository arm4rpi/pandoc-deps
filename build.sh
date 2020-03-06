#!/bin/bash

set -e

[ $# -lt 1 ] && echo "$0 pkg" && exit 1

ARCH=`arch`

echo "I am `whoami`, I will build $ARCH-$1"

cd root

apt-get update
apt-get install -y cabal-install

echo "cabal init"
cabal user-config init

echo "v2-update"
cabal v2-update

echo "v2-install $1"
cabal v2-install $1


tar zcvf $ARCH-$1.tar.gz /root/.cabal/store/ghc-8.6.5/

echo "Finish $ARCH-$1.tar.gz"
