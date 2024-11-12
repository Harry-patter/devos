#!/bin/bash

# 设置一些常用的路径变量
ISODIR="isodir"
GRUBDIR="$ISODIR/boot/grub"

# 创建必要的目录结构
echo "Creating directory structure..."
mkdir -p "$GRUBDIR"

# 复制文件到目标目录
echo "Copying files..."
cp myos.bin "$ISODIR/boot/myos.bin"
cp grub.cfg "$GRUBDIR/grub.cfg"

# 生成 ISO 文件
echo "Generating ISO..."
grub-mkrescue -o myos.iso "$ISODIR"

echo "ISO file 'myos.iso' has been successfully created."
