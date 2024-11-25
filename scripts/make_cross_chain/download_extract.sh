#!/bin/bash

# 获取源码

# 创建交叉编译链目录
cross_dir="$HOME/cross"
mkdir -p $cross_dir/{tar,src,build/{binutils,gcc,gdb}}

# 定义文件名和 URL 列表
urls=(
    "https://ftp.gnu.org/gnu/binutils/binutils-2.43.1.tar.gz"
    "https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.gz"
    "https://ftp.gnu.org/gnu/gdb/gdb-15.2.tar.gz"
)

all_tarfiles=()
# 循环处理每个 URL
for url in "${urls[@]}"; do
    # 提取文件名
    filename=$(basename "$url")
    all_tarfiles+=("$filename")
    
    # 检查文件是否已存在
    if [ -f "$cross_dir/tar/$filename" ]; then
        echo "File '$filename' already exists, skipping download."
    else
        echo "Downloading: $url"
        wget -P $cross_dir/tar "$url"
    fi
done


# 循环处理 cross/tar 目录下的所有 .tar.gz 文件
for tarfile in "${all_tarfiles[@]}"; do
    # 检查文件是否存在
    if [ -f "$cross_dir/tar/$tarfile" ]; then
        echo "Extracting: $tarfile"
        # 使用 tar 解压文件到 cross/src 目录
        tar -xzvf "$cross_dir/tar/$tarfile" -C $cross_dir/src
    else
        echo "No .tar.gz files found in cross/tar"
        break
    fi
done
