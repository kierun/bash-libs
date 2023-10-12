#!/bin/bash
# https://sylvaindurand.org/dynamic-wallpapers-with-sway/
img="$HOME/Pictures/wallpapers/"    # The full path to your wallpapers.
delay=600                           # in seconds.

# Do not change anything below this line unless you know what you are doing.
all_images=$(find "$img" -type f | file --mime-type -f - | grep -F image/ | rev | cut -d : -f 2- | rev)
while true; do
    cur=$(echo "$all_images" | shuf -n1)
    echo "$cur"
    PID=$(pidof swaybg)
    swaybg -i "$cur" -m fill &
    kill "$PID"
    echo "PID=$PID"
    sleep "$delay"
done
