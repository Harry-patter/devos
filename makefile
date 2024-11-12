# 交叉编译器
CC = x86_64-elf-gcc
AS = x86_64-elf-as
LD = x86_64-elf-ld

# 编译选项
CFLAGS = -ffreestanding -O2 -Wall -Wextra -std=gnu17
ASFLAGS = 
LDFLAGS = -T linker.ld -nostdlib -lgcc

# 源文件
SOURCES = kernel.c boot.s
OBJECTS = boot.o kernel.o
OUTPUT = myos.bin

# 默认目标
all: $(OUTPUT)

# 生成 myos.bin 文件
$(OUTPUT): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $(OUTPUT) $(OBJECTS)

# 编译 boot.s 为 boot.o
boot.o: boot.s
	$(AS) boot.s -o boot.o

# 编译 kernel.c 为 kernel.o
kernel.o: kernel.c
	$(CC) $(CFLAGS) -c kernel.c -o kernel.o

# 清理中间文件
clean:
	rm -f $(OBJECTS) $(OUTPUT)

.PHONY: all clean
