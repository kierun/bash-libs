#!/bin/bash
for file in "$@"; do
    clean_file="$file" # Probably not worth trying to fix the file name…
    filename=$(basename -- "$clean_file")
    dst="$HOME/Pictures/gifs"
    # extension="${filename##*.}"
    filename="${filename%.*}"
    echo "Doing $clean_file →  $dst/$filename.gif"
    ffmpeg -i "$clean_file" -r 24 -vf scale=1024:-1 -v warning "$dst/$filename.gif"
    mv -i "$clean_file" "$dst"
done
