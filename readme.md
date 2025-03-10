# 编译汇编
x86_64-elf-cpp boot.s boot_temp.s
x86_64-elf-cpp boot_temp.s -o boot.s

sudo apt-get install ovmf

# qemu
sudo useradd -g $USER libvirt
sudo useradd -g $USER libvirt-kvm

sudo systemctl enable libvirtd.service && sudo systemctl start libvirtd.service
重启reboot

gdb
file build/myos.bin
set architecture i386:x86-64
target remote:1234

gdb -x gdb.gdb

# 设置断点
b multiboot_header
# 继续
c
# 步进
step

x/[n][f][u] address

    [n] 是显示的单元数，默认为 1。
    [f] 是显示的格式（如 x、d、u 等）。
    [u] 是显示的单位（如 b、h、w、g 等）。
    address 是您要查看的内存地址。


objdump -d -j .text your_program

gdb -x scripts/os/gdb.gdb

cmake -G Ninja ../src
ninja