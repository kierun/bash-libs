#!/usr/bin/bash
# -*- coding: utf-8 -*-
################################################################################
## Configuration!

# Where are your wallpapers kept?
wallpapers=~/wallpapers

# How often you want your wallpaper to change? Passed to sleep…
frequency="10m"

# What program, with options, do you use to set your wallpaper?
setter="`which feh` --bg-scale"

# When do you want the rotating to pause. Set this above 2400 for always.
pause_time="1600"

# How long do we wish this to pause for?
pause_duration="15 hours"

# What are the days you do not wish to work on. An empty array is all the time.
skip_today=("Sat" "Sun")

################################################################################
## ⚠  Ignore things below this line…

function __wallpaper_lib_help( ) {
    cat <<- EOF
Calling: . <path>/wallpaper.bash

This file needs a bit of work to make it an includable lib, rather than a
standalone process.

EOF
    exit 0
}

# Function that returns 0 if and element is in the array.
function containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}
function runToday() {
    local d
    d=$(date +%a)
    for s in ${skip_today[@]}; do
        if [ $s == $d ]; then
            return 0
        fi
    done
    return 1
}

# Do the hard work…
while true; do

    # Get all the yearly directories.
    shopt -s nullglob
    yeardirs=(${wallpapers}/2*/) 
    shopt -u nullglob

    # Add as many instances of preferred as there are yearly directories.
    for i in $(eval echo "{0..${#yeardirs[@]}}")
    do
        dirs+=(${wallpapers}/preferred)
    done

    # Add each yearly directory to the main list, starting with the earlier.
    END=$((${#yeardirs[@]} - 1))
    for i in $(eval echo "{0..$END}")
    do
        for j in $(eval echo "{0..$i}")
        do
            dirs+=(${yeardirs[$i]})
        done
    done

    # Now, get all the files and shuffle them!
    array+=($(/usr/bin/find "${dirs[@]}" -type f | shuf))

    # Loop through the array, set as back drop, and sleep till next time.
    COUNTER=0
    for img in "${array[@]}"; do
        runToday
        if [ $? -gt 0 ]; then
        #if containsElement `date +'%a'` "${skip_today[@]}"; then
            # We can run, but when?
            now=`date +'%H%M'`
            if [ $now -ge $pause_time ];
            then
                # This is outside the end time!
                echo "It's late, go home!"
                current_epoch=$(date +%s)
                target_epoch=$(date -d "${pause_duration}" +%s)
                sleep_seconds=$(( $target_epoch - $current_epoch ))
                sleep $sleep_seconds
            else
                # We can set the wallpaper.
                let COUNTER=COUNTER+1
                echo "`date` ${COUNTER}/${#array[@]}: $img"
                $setter $img
                sleep $frequency
            fi
        else
            # Do not run this day.
            echo "This is the weekend"
            current_epoch=$(date +%s)
            target_epoch=$(date -d "tomorrow" +%s)
            sleep_seconds=$(( $target_epoch - $current_epoch ))
            sleep $sleep_seconds
        fi
    done
done
# eof

this=$(realpath $BASH_SOURCE)
orig=$(realpath $0)

if [ $this == $orig ]; then
    __wallpaper_lib_help
fi
