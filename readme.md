# 编译汇编
x86_64-elf-cpp boot.s boot_temp.s
x86_64-elf-cpp boot_temp.s -o boot.s

sudo apt-get install ovmf

# qemu
sudo useradd -g $USER libvirt
sudo useradd -g $USER libvirt-kvm

sudo systemctl enable libvirtd.service && sudo systemctl start libvirtd.service
重启reboot