#!/bin/bash

TARGET=${1:-$HOME/bin/lib}

# get our sources
src=$(realpath "$0")
dir=$(dirname "$src")
cd "$dir" || exit 1

# files=($(/bin/ls -1f | grep 'bash$' | grep -Fv install.bash))
mapfile -t files < <(/bin/ls -1f | grep 'bash$' | grep -Fv install.bash)

mkdir -p "$TARGET"

for f in "${files[@]}"; do
    install -m755 -pv "$f" "$TARGET/$f"
done
