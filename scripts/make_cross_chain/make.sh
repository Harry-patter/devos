#!/bin/bash

# 构建交叉编译链

# 检查依赖
dependencies=(
    "build-essential"
    "bison"
    "flex"
    "libgmp3-dev"
    "libmpc-dev"
    "libmpfr-dev"
    "texinfo"
    "libisl-dev"
)

for dep in "${dependencies[@]}"; do
    if dpkg-query -l "$dep" &> /dev/null; then
        echo "$dep is installed."
    else
        echo "$dep is NOT installed."
    fi
done


# 交叉编译链目录
cross_dir="$HOME/cross"

export PREFIX="$cross_dir"
export TARGET=x86_64-elf
export PATH="$PREFIX/bin:$PATH"

build_binutils() {
    echo "=== Building Binutils ==="
    cd $cross_dir/build/binutils
    $cross_dir/src/binutils-2.43.1/configure --target=$TARGET --prefix=$PREFIX --with-sysroot --disable-nls --disable-werror
    make -j$(nproc) || exit
    make install || exit
    echo "=== Binutils built successfully ==="
}

build_gcc() {
    echo "=== Building gcc ==="
    cd $cross_dir/build/gcc
    $cross_dir/src/gcc-14.2.0/configure --target=$TARGET --prefix=$PREFIX -disable-nls --enable-languages=c,c++ --without-headers
    make all-gcc -j$(nproc) || exit
    make all-target-libgcc -j$(nproc) || exit
    make install-gcc || exit
    make install-target-libgcc || exit
    echo "=== gcc built successfully ==="
}

build_gdb() {
    echo "=== Building gdb ==="
    cd $cross_dir/build/gdb
    $cross_dir/src/gdb-15.2/configure --target=$TARGET --prefix=$PREFIX --disable-werror --with-expat
    make all-gdb -j$(nproc) || exit
    make install-gdb || exit
    echo "=== gdb built successfully ==="
}

# 启动并行构建
build_binutils &
BINUTILS_PID=$!

# 等待 Binutils 完成后启动 GCC 和 GDB
wait $BINUTILS_PID

# 并行构建 GCC 和 GDB
build_gcc &
build_gdb &
wait

# 添加环境变量
echo 'export PATH="$PREFIX/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo "=== All components built successfully ==="
