#!/bin/bash

CIDIR=".github/workflows"
CICONF="$CIDIR/main.yml"

[ ! -d $CIDIR ] && mkdir -p $CIDIR

cat > $CICONF <<EOF
name: Pandoc Arm Deps
on: [push]
jobs:
EOF

for id in `cat deps.txt |grep -v "#" |sort -u`;do
	cat >> $CICONF <<EOF

  aarch64-$id:
    runs-on: ubuntu-latest
    steps:
    - name: build
      run: |
        sudo apt-get update
        sudo apt-get install -y qemu-user-static aria2
        aria2c -x 16 http://cdimage.ubuntu.com/ubuntu-base/releases/19.10/release/ubuntu-base-19.10-base-arm64.tar.gz
        mkdir rootfs
        mkdir bin
        cd rootfs
        tar xvf ../ubuntu-base-19.10-base-arm64.tar.gz
        cp /usr/bin/qemu-aarch64-static usr/bin
        cp /etc/resolv.conf etc
        cp ../build.sh .
        sudo mount -t devtmpfs devtmpfs dev
        sudo mount -t devpts devpts dev/pts
        sudo mount -t sysfs sysfs sys
        sudo mount -t tmpfs tmpfs tmp
        sudo mount -t proc proc proc
        sudo chroot . /build.sh $id
    - name: release
      run: |
        ID=`curl -s -H "Authorization: token \${{ secrets.GITHUB_TOKEN }}" "https://api.github.com/repos/arm4rpi/pandoc-deps/releases/tags/v0.1" |grep '"id"' |head -n 1 |awk '{print $2}' |tr -d ','`
		curl -H "Authorization: token \${{ secrets.GITHUB_TOKEN }}" -H "Content-Type: application/x-gzip" "https://uploads.github.com/repos/arm4rpi/pandoc-deps/releases/\$ID/assets?name=aarch64-$id.tar.gz" --data-binary @aarch64-$id.tar.gz


  armv7l-$id:
    runs-on: ubuntu-latest
    steps:
    - name: build
      run: |
        sudo apt-get update
        sudo apt-get install -y qemu-user-static aria2
        aria2c -x 16 http://cdimage.ubuntu.com/ubuntu-base/releases/19.10/release/ubuntu-base-19.10-base-armhf.tar.gz
        mkdir rootfs
        mkdir bin
        cd rootfs
        tar xvf ../ubuntu-base-19.10-base-armhf.tar.gz
        cp /usr/bin/qemu-arm-static usr/bin
        cp /etc/resolv.conf etc
        cp ../build.sh .
        sudo mount -t devtmpfs devtmpfs dev
        sudo mount -t devpts devpts dev/pts
        sudo mount -t sysfs sysfs sys
        sudo mount -t tmpfs tmpfs tmp
        sudo mount -t proc proc proc
        sudo chroot . /build.sh $id
    - name: release
      run: |
        ID=`curl -s -H "Authorization: token \${{ secrets.GITHUB_TOKEN }}" "https://api.github.com/repos/arm4rpi/pandoc-deps/releases/tags/v0.1" |grep '"id"' |head -n 1 |awk '{print $2}' |tr -d ','`
		curl -H "Authorization: token \${{ secrets.GITHUB_TOKEN }}" -H "Content-Type: application/x-gzip" "https://uploads.github.com/repos/arm4rpi/pandoc-deps/releases/\$ID/assets?name=arm-$id.tar.gz" --data-binary @arm-$id.tar.gz
EOF
done
