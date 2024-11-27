gdb
file build/myos.bin
set architecture i386:x86-64
target remote:1234

# 设置断点
b multiboot_header
# 继续
c

x/[n][f][u] address

    [n] 是显示的单元数，默认为 1。
    [f] 是显示的格式（如 x、d、u 等）。
    [u] 是显示的单位（如 b、h、w、g 等）。
    address 是您要查看的内存地址。