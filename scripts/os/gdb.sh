#!/bin/bash
script_dir=$(dirname "$(readlink -f "$0")")
project_dir="$script_dir/../.."

gdb -x $script_dir/gdb.gdb $project_dir/build/isodir/boot/myos