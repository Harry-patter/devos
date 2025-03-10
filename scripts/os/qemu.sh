#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")
project_dir="$script_dir/../.."


isofile="$project_dir/build/kernel.iso"
qemu-system-x86_64 \
	-enable-kvm \
	-bios /usr/share/ovmf/OVMF.fd \
	-cpu host,+smep,+smap \
	-smp sockets=1,dies=1,cores=1,threads=1 \
	-m 4G \
	--machine q35 \
	-cdrom $isofile \
	-s -S -monitor stdio \

# gdb -x $script_dir/gdb.gdb
