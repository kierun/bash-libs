#!/bin/bash

while getopts "hsp" opt; do
    case "$opt" in
    h)
        echo "Usage: $0 [-c] [-f] [-h]"
        echo "-s for speakers"
        echo "-h for headphones"
        echo "-h for help"
        echo "   No option switches from one to the other."
        exit 0
        ;;
    s)
        echo "Switching to speakers"
        pactl set-sink-port 0 analog-output-lineout
        pactl set-sink-volume 0 69%
        ;;
    p)
        echo "Switching to headphones!"
        pactl set-sink-port 0 analog-output-headphones
        pactl set-sink-volume 0 50%
        ;;
    *)
        if pactl list sinks | grep -i "Active Port" | grep -i "headphones" >/dev/null; then
            # We have headphones, therefore we want to swtich to speakers.
            echo "Swtichinmg from headphones to line out."
            pactl set-sink-port 0 analog-output-lineout
            pactl set-sink-volume 0 69%
        else
            # We have speakers, therefore we want to swtich to headphone.
            echo "Swtichinmg from line out to headphones."
            pactl set-sink-port 0 analog-output-headphones
            pactl set-sink-volume 0 50%
        fi
        ;;
    esac
done
