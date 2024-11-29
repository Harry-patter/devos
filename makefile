# 交叉编译器，可用系统自带的gcc替代
CC = x86_64-elf-gcc
LD = x86_64-elf-ld

# 可用gcc替代
# CPP = x86_64-elf-cpp
# AS = x86_64-elf-as
# LD = x86_64-elf-ld

# 编译选项
# CFLAGS = -ffreestanding -O2 -Wall -Wextra -std=gnu17 -nostartfiles
# CFLAGS = -m32 -g -fno-builtin -fno-stack-protector -nostartfiles
CFLAGS = -g -fno-builtin -fno-stack-protector -nostartfiles
# ASFLAGS = -f elf64 # 使用as时
# LDFLAGS = -melf_i386 -T linker.ld -nostdlib
LDFLAGS = -T linker.ld -nostdlib
# LDFLAGS = -Ttext 0x100000 -melf_i386 -nostdlib # 不使用自定义的脚本时

# 源文件和目标文件夹
SRC_DIR = src
BUILD_DIR = build

# 源文件
SOURCES = $(wildcard $(SRC_DIR)/*.S $(SRC_DIR)/*.c)
OBJECTS = $(patsubst $(SRC_DIR)/%.S, $(BUILD_DIR)/%.o, $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SOURCES)))
OUTPUT = $(BUILD_DIR)/kernel.bin

# 默认目标
all: $(OUTPUT)

# 生成 kernel.bin 文件
$(OUTPUT): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $(OUTPUT) $(OBJECTS)

# 生成目标文件：boot.o 从 boot_temp.S
$(BUILD_DIR)/boot.o: $(SRC_DIR)/boot.S | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) $(SRC_DIR)/boot.S -o $(BUILD_DIR)/boot.o

# 编译 kernel.c 为 kernel.o
$(BUILD_DIR)/kernel.o: $(SRC_DIR)/kernel.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $(SRC_DIR)/kernel.c -o $(BUILD_DIR)/kernel.o

# 清理中间文件
clean:
	rm -rf $(BUILD_DIR)

# 创建构建目录
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: all clean