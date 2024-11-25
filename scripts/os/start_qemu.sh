#!/bin/sh
qemu-system-x86_64 \
	-bios /usr/share/ovmf/OVMF.fd \
	-cpu kvm64,+smep,+smap \
	-smp sockets=1,dies=1,cores=1,threads=1 \
	-m 1G \
	--machine q35 \
	-cdrom  myos.iso