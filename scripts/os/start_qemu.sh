#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")
isofile="$script_dir/../../isofile/kernel.iso"

if [[ $1 == "efi" ]]; then
	qemu-system-x86_64 \
		-bios /usr/share/ovmf/0xB8000.fd \
		-cpu kvm64,+smep,+smap \
		-smp sockets=1,dies=1,cores=1,threads=1 \
		-m 4G \
		--machine q35 \
		-cdrom  $isofile \
		-s -S -monitor stdio 
elif [[ $1 == "noefi" ]]; then
	qemu-system-x86_64 \
		-cpu host,kvm64,+smep,+smap \
		-smp sockets=1,dies=1,cores=1,threads=1 \
		-m 4G \
		--machine q35 \
		-cdrom $isofile \
		-s -S -monitor stdio 
else
	qemu-system-x86_64 -s -S -cpu host -cdrom  $isofile -no-reboot -no-shutdown --enable-kvm -chardev stdio,id=gdb0 -device isa-debugcon,iobase=0x402,chardev=gdb0,id=d1 -d int -M smm=off -m 512M -M q35 -smp 1 -netdev user,id=net0 -device e1000,netdev=net0,mac=DE:AD:69:BE:EF:42
fi
