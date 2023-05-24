#!/bin/bash

while getopts "h?sp" opt; do
    case "$opt" in
        h | \?)
            echo "Usage: $0 [-c] [-f] [-h]"
            echo "-s for speakers"
            echo "-h for headphones"
            echo "-h for help"
            exit 0
            ;;
        s)
            echo "Switching to speakers"
            pactl set-sink-port 0 analog-output-lineout
            ;;
        p)
            echo "Switching to headphones!"
            pactl set-sink-port 0 analog-output-headphones
            ;;
    esac
done
