#!/bin/sh

script_dir=$(dirname "$(readlink -f "$0")")
isofile="$script_dir/../../isofile/iso/myos.iso"
qemu-system-x86_64 \
	-bios /usr/share/ovmf/OVMF.fd \
	-cpu kvm64,+smep,+smap \
	-smp sockets=1,dies=1,cores=1,threads=1 \
	-m 4G \
	--machine q35 \
	-cdrom  $isofile