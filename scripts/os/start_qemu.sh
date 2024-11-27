#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")
isofile="$script_dir/../../isofile/myos.iso"

if [[ $1 == "efi" ]]; then
	qemu-system-x86_64 \
		-bios /usr/share/ovmf/OVMF.fd \
		-cpu kvm64,+smep,+smap \
		-smp sockets=1,dies=1,cores=1,threads=1 \
		-m 4G \
		--machine q35 \
		-cdrom  $isofile \
		-s -S -monitor stdio \
		-nographic
else
	qemu-system-x86_64 \
		-cpu kvm64,+smep,+smap \
		-smp sockets=1,dies=1,cores=1,threads=1 \
		-m 4G \
		--machine q35 \
		-cdrom $isofile \
		-s -S -monitor stdio 
fi

# qemu-system-x86_64 \
# 	-bios /usr/share/ovmf/OVMF.fd \
# 	-m 1G \
# 	-cdrom  $isofile \
# 	-s -S -monitor stdio \
# 	# -bios /usr/share/ovmf/OVMF.fd \
# 	-cpu kvm64,+smep,+smap \
# 	-smp sockets=1,dies=1,cores=1,threads=1 \
# 	# --machine q35 \
