#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")
isofile="$script_dir/../../isofile/myos.iso"


qemu-system-x86_64 -m 1G -cdrom  $isofile -s -S -monitor stdio
	# -bios /usr/share/ovmf/OVMF.fd \
	# -cpu kvm64,+smep,+smap \
	# -smp sockets=1,dies=1,cores=1,threads=1 \
	# --machine q35 \
