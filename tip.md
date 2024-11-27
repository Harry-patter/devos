gdb
file build/myos.bin
set architecture i386:x86-64
target remote:1234

# 设置断点
b multiboot_header
# 继续
c