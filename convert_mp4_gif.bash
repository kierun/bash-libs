#!/bin/bash

ffmpeg \
    -i "$1" \
    -r 24 \
    -vf scale=1024:-1 \
    "$2"
