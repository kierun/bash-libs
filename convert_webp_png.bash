#!/bin/bash

for file in *.webp; do
    base=$(basename "${file}" .webp)
    dwebp -mt "${file}" -o "${base}".png
done
