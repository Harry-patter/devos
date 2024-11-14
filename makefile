# 交叉编译器
CC = x86_64-elf-gcc
CPP = x86_64-elf-cpp
AS = x86_64-elf-as
LD = x86_64-elf-gcc

# 编译选项
CFLAGS = -ffreestanding -O2 -Wall -Wextra -std=gnu17  
ASFLAGS = -f elf32 
LDFLAGS = -T linker.ld -ffreestanding -nostdlib -lgcc

# 源文件
SOURCES = boot.s kernel.c
OBJECTS = boot.o kernel.o 
OUTPUT = myos.bin

# 默认目标
all: $(OUTPUT)

# 生成 myos.bin 文件
$(OUTPUT): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $(OUTPUT) $(OBJECTS)

# 生成目标文件：boot_temp.s 从 boot.s
boot_temp.s: boot.s
	$(CPP) boot.s > boot_temp.s

# 生成目标文件：boot.o 从 boot_temp.s
boot.o: boot_temp.s
	$(AS) boot_temp.s -o boot.o

# 编译 kernel.c 为 kernel.o
kernel.o: kernel.c
	$(CC) $(CFLAGS) -c kernel.c -o kernel.o

# 清理中间文件
clean:
	rm -f $(OBJECTS) $(OUTPUT)

.PHONY: all clean
