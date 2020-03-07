#!/bin/bash

CIDIR=".github/workflows"
CICONF="$CIDIR/main.yml"

[ ! -d $CIDIR ] && mkdir -p $CIDIR

cat > $CICONF <<EOF
name: Pandoc Arm Deps
on: [push]
jobs:
EOF

for id in `cat deps.txt |sed '/^$/d'|grep -v "#" |sort -u`;do
	jobid=`echo $id|tr '.' '_'`
	cat >> $CICONF <<EOF

  aarch64-$jobid:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: build
      run: |
        sudo apt-get update
        sudo apt-get install -y qemu-user-static aria2
        aria2c -x 16 http://cdimage.ubuntu.com/ubuntu-base/releases/19.10/release/ubuntu-base-19.10-base-arm64.tar.gz
        mkdir rootfs
        cd rootfs
        echo "decompression rootfs"
        tar xvf ../ubuntu-base-19.10-base-arm64.tar.gz &>/dev/null && echo "decompression rootfs successfull"
        cp /usr/bin/qemu-aarch64-static usr/bin
        cp /etc/resolv.conf etc
        cp ../build.sh $id
        sudo mount -t devtmpfs devtmpfs dev
        sudo mount -t devpts devpts dev/pts
        sudo mount -t sysfs sysfs sys
        sudo mount -t tmpfs tmpfs tmp
        sudo mount -t proc proc proc
        echo "chroot to arm"
        sudo chroot . /$id
    - name: Upload Release Asset
      id: upload-release-asset 
      uses: svenstaro/upload-release-action@v1-release
      with:
        repo_token: \${{ secrets.TOKEN }} # See: https://github.community/t5/GitHub-Actions/error-Bad-credentials/td-p/33500
        file: ./rootfs/aarch64-$id.tar.gz
        asset_name: aarch64-$id.tar.gz
        tag: v0.1
        overwrite: true

  armv7l-$jobid:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: build
      run: |
        sudo apt-get update
        sudo apt-get install -y qemu-user-static aria2
        aria2c -x 16 http://cdimage.ubuntu.com/ubuntu-base/releases/19.10/release/ubuntu-base-19.10-base-armhf.tar.gz
        mkdir rootfs
        cd rootfs
        echo "decompression rootfs"
        tar xvf ../ubuntu-base-19.10-base-armhf.tar.gz &>/dev/null && echo "decompression rootfs successfull"
        cp /usr/bin/qemu-arm-static usr/bin
        cp /etc/resolv.conf etc
        cp ../build.sh $id
        sudo mount -t devtmpfs devtmpfs dev
        sudo mount -t devpts devpts dev/pts
        sudo mount -t sysfs sysfs sys
        sudo mount -t tmpfs tmpfs tmp
        sudo mount -t proc proc proc
        echo "chroot to arm"
        sudo chroot . /$id
    - name: Upload Release Asset
      id: upload-release-asset 
      uses: svenstaro/upload-release-action@v1-release
      with:
        repo_token: \${{ secrets.TOKEN }} # See: https://github.community/t5/GitHub-Actions/error-Bad-credentials/td-p/33500
        file: ./rootfs/armv7l-$id.tar.gz
        asset_name: armv7l-$id.tar.gz
        tag: v0.1
        overwrite: true
EOF
done
