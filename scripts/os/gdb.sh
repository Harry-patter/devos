#!/bin/bash
script_dir=$(dirname "$(readlink -f "$0")")
x86_64-elf-gdb -x $script_dir/gdb.gdb