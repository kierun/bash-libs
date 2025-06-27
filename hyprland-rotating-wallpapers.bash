#!/bin/bash
################################################################################
# A (trivial) script to have a rotating wallpaper with hyprpaper.
#
# You can use it in cron like so:
#           */15 7-19 * * * /usr/bin/chronic /home/$USER/bin/hyprland-rotating-wallpapers.bash
#
# The reason I have chronic is so that any errors get logged.
################################################################################

# Where you top level wallpaper directory is. Note that this work for sub directories too!
WALLPAPER_DIRECTORY=~/Pictures/wallpapers
WALLPAPER=$(find "$WALLPAPER_DIRECTORY" -type f | shuf -n 1)

# Set the random wallpaper
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper "Virtual-1,$WALLPAPER" # Change or add as needed…

# Sleep for a bit… Just in case. Paranoid much?
sleep 2

# Clear the cache.
hyprctl hyprpaper unload unused
