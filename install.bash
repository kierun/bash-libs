#!/bin/bash

TARGET=${1:-$HOME/bin}

# get our sources
src=$(realpath "$0")
dir=$(dirname "$src")
cd "$dir" || exit 1

# files=($(/bin/ls -1f | grep 'bash$' | grep -Fv install.bash))
mapfile -t files < <(/bin/ls -1f | grep 'sh$' | grep -Fv install.bash)

mkdir -p "$TARGET"

for f in "${files[@]}"; do
    ln -si "$(pwd)"/"$f" "$TARGET/"
done
