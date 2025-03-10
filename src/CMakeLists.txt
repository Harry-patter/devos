cmake_minimum_required(VERSION 3.10)

# 设置项目名称
project(devos)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# 使用 Clang 编译器
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)

set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 添加汇编支持
enable_language(ASM)
# 添加编译选项
# 添加链接选项
add_compile_options(-ffreestanding -nostdlib -fno-pie -nostartfiles -fno-stack-protector -mcmodel=large -fno-asynchronous-unwind-tables -fno-exceptions)
# 添加链接选项
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -no-pie -nostartfiles -z noexecstack -T ${CMAKE_SOURCE_DIR}/linker.ld ")
# 设置链接选项，明确指定栈不可执行
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -z noexecstack")

# 添加源文件
set(SOURCES
    boot.S
    kernel.cpp
)

# 添加可执行文件
add_executable(myos ${SOURCES})

# 设置可执行文件的输出路径
set_target_properties(myos PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/isodir/boot
)

# 复制镜像目录
file(COPY ${CMAKE_SOURCE_DIR}/isodir DESTINATION ${CMAKE_BINARY_DIR})

# 定义要创建 ISO 文件的目录和输出的 ISO 文件路径
set(ISO_DIR "${CMAKE_BINARY_DIR}/isodir")
set(ISO_FILE "${CMAKE_BINARY_DIR}/kernel.iso")
# 添加自定义目标
add_custom_target(create_iso ALL
    COMMAND grub-mkrescue -o ${ISO_FILE} ${ISO_DIR}
    COMMENT "Creating ISO image: ${ISO_FILE}"
)



