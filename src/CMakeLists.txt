# Set the minimum required version of CMake
cmake_minimum_required(VERSION 3.10)

# Project name
project(kernel C CXX ASM)

# Set standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_C_STANDARD 11)

# Set cross-compiler
set(CMAKE_C_COMPILER x86_64-elf-gcc)
set(CMAKE_CXX_COMPILER x86_64-elf-g++)
set(CMAKE_ASM_COMPILER x86_64-elf-gcc)
set(CMAKE_LINKER x86_64-elf-ld)

# Set compilation options
set(CMAKE_C_FLAGS "-g -ffreestanding -Wextra -fno-builtin -fno-stack-protector -nostartfiles -Wno-int-to-pointer-cast -Wno-pointer-to-int-cast")
set(CMAKE_ASM_FLAGS "-g -ffreestanding -Wextra -fno-builtin -fno-stack-protector -nostartfiles -Wno-int-to-pointer-cast -Wno-pointer-to-int-cast")

# Set the linker script
set(CMAKE_LINKER_SCRIPT "${CMAKE_SOURCE_DIR}/linker.ld")
set(CMAKE_EXE_LINKER_FLAGS "-nostdlib -T ${CMAKE_LINKER_SCRIPT}")

# Set the source and build directories
set(SRC_DIR ${CMAKE_SOURCE_DIR})
set(BUILD_DIR ${CMAKE_SOURCE_DIR}/../build)
include_directories(${CMAKE_SOURCE_DIR}/../include)
message(STATUS "src dir: ${SRC_DIR}")

# Source files
file(GLOB SOURCES "${SRC_DIR}/boot/*.S" "${SRC_DIR}/boot/*.c")
message(STATUS "source files: ${SOURCES}")

# Add executable file
add_executable(kernel.bin ${SOURCES})
