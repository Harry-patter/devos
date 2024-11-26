#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")
isofile="$script_dir/../../isofile/iso/myos.iso"
binfile="$script_dir/../../isofile/bin/myos.bin"
if [[ $1 == "iso" ]]; then
	qemu-system-x86_64 -m 1G -cdrom  $isofile
		# -bios /usr/share/ovmf/OVMF.fd \
		# -cpu kvm64,+smep,+smap \
		# -smp sockets=1,dies=1,cores=1,threads=1 \
		#  \
		# --machine q35 \
		# -cdrom  $isofile
elif [[ $1 == "bin" ]]; then
	qemu-system-x86_64 \
		# -bios /usr/share/ovmf/OVMF.fd \
		# -cpu kvm64,+smep,+smap \
		# -smp sockets=1,dies=1,cores=1,threads=1 \
		-m 4G \
		# --machine q35 \
		-kernel $binfile
else
	echo "Usage: $0 [iso|bin]"
fi