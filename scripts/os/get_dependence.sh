#!/bin/bash

# 安装工具链

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g., sudo $0)"
  exit 1
fi

# 定义需要安装的依赖
DEPENDENCIES=(
  qemu 
  qemu-kvm 
  virt-manager 
  bridge-utils
  xorriso
  ovmf
)

# 更新包列表
echo "Updating package list..."
apt update || { echo "Failed to update package list"; exit 1; }

# 安装依赖
echo "Installing dependencies..."
apt install -y "${DEPENDENCIES[@]}" || { echo "Failed to install dependencies"; exit 1; }

echo "All dependencies installed successfully!"