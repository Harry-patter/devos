#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")
project_dir="$script_dir/../.."

mkdir -p "$project_dir/build"
cd "$project_dir/build"
cmake -G Ninja ../src
ninja
cd ..