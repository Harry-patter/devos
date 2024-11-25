#!/bin/bash

# 设置一些常用的路径变量
iso_dir="isodir"
grub_dir="$iso_dir/boot/grub"

script_dir=$(dirname "$(readlink -f "$0")")
bin_dir="$script_dir/../../build/myos.bin"
isofile="$script_dir/../../isofile/iso"

# 创建必要的目录结构
echo "Creating directory structure..."
mkdir -p "$grub_dir"
mkdir -p "$isofile"

# 复制文件到目标目录
echo "Copying files..."
cp $bin_dir "$iso_dir/boot/myos.bin"
cp $bin_dir "$isofile/bin/myos.bin"

# 生成 ISO 文件
echo "Generating ISO..."
grub-mkrescue -o "$isofile/myos.iso" "$iso_dir"

echo "ISO file 'myos.iso' has been successfully created."
