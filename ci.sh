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
        cp ../build.sh .
        sudo mount -t devtmpfs devtmpfs dev
        sudo mount -t devpts devpts dev/pts
        sudo mount -t sysfs sysfs sys
        sudo mount -t tmpfs tmpfs tmp
        sudo mount -t proc proc proc
        echo "chroot to arm"
        chroot . /build.sh $id
    - name: release
      run: |
        ID=\`curl -s -H "Authorization: token \${{ secrets.GITHUB_TOKEN }}" "https://api.github.com/repos/arm4rpi/pandoc-deps/releases/tags/v0.1" |grep '"id"' |head -n 1 |awk '{print $2}' |tr -d ','\`
        curl -H "Authorization: token \${{ secrets.GITHUB_TOKEN }}" -H "Content-Type: application/x-gzip" "https://uploads.github.com/repos/arm4rpi/pandoc-deps/releases/\$ID/assets?name=aarch64-$id.tar.gz" --data-binary @aarch64-$id.tar.gz


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
        cp ../build.sh .
        sudo mount -t devtmpfs devtmpfs dev
        sudo mount -t devpts devpts dev/pts
        sudo mount -t sysfs sysfs sys
        sudo mount -t tmpfs tmpfs tmp
        sudo mount -t proc proc proc
        echo "chroot to arm"
        chroot . /build.sh $id
    - name: release
      run: |
        ID=\`curl -s -H "Authorization: token \${{ secrets.GITHUB_TOKEN }}" "https://api.github.com/repos/arm4rpi/pandoc-deps/releases/tags/v0.1" |grep '"id"' |head -n 1 |awk '{print $2}' |tr -d ','\`
        curl -H "Authorization: token \${{ secrets.GITHUB_TOKEN }}" -H "Content-Type: application/x-gzip" "https://uploads.github.com/repos/arm4rpi/pandoc-deps/releases/\$ID/assets?name=armv7l-$id.tar.gz" --data-binary @armv7l-$id.tar.gz
EOF
done
