#!/bin/bash

CIDIR=".github/workflows"
CICONF="$CIDIR/main.yml"

[ ! -d $CIDIR ] && mkdir -p $CIDIR

cat > $CICONF <<EOF
name: Pandoc Arm Deps
on: [push]
jobs:
EOF

function addJob() {
	id=$1
	arch=$2
	jobid=`echo $id|tr '.' '_'`
	qemuarch=aarch64
	ubuntuarch=arm64
	[ "$arch"x == "armv7l"x ] && qemuarch="arm" && ubuntuarch="armhf"

	cat >> $CICONF <<EOF

  $arch-$jobid:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: build
      run: |
        mkdir rootfs
        curl -s -L "https://github.com/arm4rpi/pandoc-deps/releases/download/v0.1/$arch-$id.tar.gz" -o rootfs/$arch-$id.tar.gz
        MIME=\`file -b --mime-type rootfs/$arch-$id.tar.gz\`
        echo \$MIME
        [ "\$MIME"x == "application/gzip"x ] && echo "Already exists" && exit 0 || echo "Not exists"
        sudo apt-get update
        sudo apt-get install -y qemu-user-static aria2
        aria2c -x 16 http://cdimage.ubuntu.com/ubuntu-base/releases/19.10/release/ubuntu-base-19.10-base-$ubuntuarch.tar.gz
        cd rootfs
        echo "decompression rootfs"
        tar xvf ../ubuntu-base-19.10-base-$ubuntuarch.tar.gz &>/dev/null && echo "decompression rootfs successfull"
        cp /usr/bin/qemu-$qemuarch-static usr/bin
        cp /etc/resolv.conf etc
        cp ../build.sh $id
        sudo mount -t devtmpfs devtmpfs dev
        sudo mount -t devpts devpts dev/pts
        sudo mount -t sysfs sysfs sys
        sudo mount -t tmpfs tmpfs tmp
        sudo mount -t proc proc proc
        echo "chroot to arm"
        sudo chroot . /$id
        echo "Upload Asset"
        curl -H "Authorization: token \${{ secrets.TOKEN }}" -H "Content-Type: application/x-gzip" "https://uploads.github.com/repos/arm4rpi/pandoc-deps/releases/24305294/assets?name=$arch-$id.tar.gz" --data-binary @rootfs/$arch-$id.tar.gz
EOF
}

for id in `cat deps.txt |sed '/^$/d'|grep -v "#" |sort -u`;do
	addJob $id aarch64
	addJob $id armv7l
done
