# 交叉编译器
CC = x86_64-elf-gcc
CPP = x86_64-elf-cpp
AS = x86_64-elf-as
LD = x86_64-elf-gcc

# 编译选项
CFLAGS = -ffreestanding -O2 -Wall -Wextra -std=gnu17  
ASFLAGS = -f elf32 
LDFLAGS = -T linker.ld -ffreestanding -nostdlib -lgcc

# 源文件和目标文件夹
SRC_DIR = src
BUILD_DIR = build

# 源文件
SOURCES = $(wildcard $(SRC_DIR)/*.s $(SRC_DIR)/*.c)
OBJECTS = $(patsubst $(SRC_DIR)/%.s, $(BUILD_DIR)/%.o, $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SOURCES)))
OUTPUT = $(BUILD_DIR)/myos.bin

# 默认目标
all: $(OUTPUT)

# 生成 myos.bin 文件
$(OUTPUT): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $(OUTPUT) $(OBJECTS)

# 生成目标文件：boot_temp.s 从 boot.s
$(BUILD_DIR)/boot_temp.s: $(SRC_DIR)/boot.s | $(BUILD_DIR)
	$(CPP) $(SRC_DIR)/boot.s > $(BUILD_DIR)/boot_temp.s

# 生成目标文件：boot.o 从 boot_temp.s
$(BUILD_DIR)/boot.o: $(BUILD_DIR)/boot_temp.s
	$(AS) $(BUILD_DIR)/boot_temp.s -o $(BUILD_DIR)/boot.o

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