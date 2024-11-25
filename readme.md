# 编译汇编
x86_64-elf-cpp boot.s boot_temp.s
x86_64-elf-cpp boot_temp.s -o boot.s

sudo apt-get install ovmf