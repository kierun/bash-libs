#!/usr/bin/bash
# -*- coding: utf-8 -*-
################################################################################
## Configuration!

# Where are your wallpapers kept?
wallpapers=~/wallpapers

# How often you want your wallpaper to change? Passed to sleep…
frequency="10m"

# What program, with options, do you use to set your wallpaper?
setter="$(which feh) --bg-scale"

# When do you want the rotating to pause. Set this above 2400 for always.
pause_time="2401"

# How long do we wish this to pause for?
pause_duration="1 hours"

# What are the days you do not wish to work on. An empty array is all the time.
skip_today=()

################################################################################
## ⚠  Ignore things below this line…

# Function that returns 0 if and element is in the array.
function containsElement() {
	local e
	for e in "${@:2}"; do [[ $e == "$1" ]] && return 0; done
	return 1
}

# Function that returns 1 if we are not running.
function runToday() {
	local d
	d=$(date +%a)
	for s in "${skip_today[@]}"; do
		if [ "$s" == "$d" ]; then
			return 1
		fi
	done
	return 0
}

# Do the hard work…
while true; do

	# Get all the old directories.
	#
	# Create an empty array to store the matching directories
	directories=()

	# Loop through all directories in the current directory
	for dir in "${wallpapers}"/*; do
		# Get the first character of the directory name
		first_char=$(basename "$dir" | cut -c1)

		# Check if the first character is a capital letter
		if [[ $first_char =~ [A-Z] ]]; then
			# Add the directory to the array
			directories+=("$dir")
		fi
	done

	# Print the matching directories
	for dir in "${directories[@]}"; do
		echo "$dir"
	done

	# Add as many instances of preferred as there are old directories.
	for i in $(eval echo "{0..${#directories[@]}}"); do
		dirs+=("${wallpapers}"/Preferred)
	done

	# Add each old directory to the main list, starting with the earlier.
	END=$((${#directories[@]} - 1))
	for i in $(eval echo "{0..$END}"); do
		for _ in $(eval echo "{0..$i}"); do
			dirs+=("${directories[$i]}")
		done
	done

	# Now, get all the files and shuffle them!
	mapfile -t array < <(find "${dirs[@]}" -type f | shuf)

	# Loop through the array, set as back drop, and sleep till next time.
	COUNTER=0
	for img in "${array[@]}"; do
		if runToday; then
			# We can run, but when?
			now=$(date +'%H%M')
			if [ "$now" -ge "$pause_time" ]; then
				# This is outside the end time!
				echo "It's late, go home!"
				current_epoch=$(date +%s)
				target_epoch=$(date -d "${pause_duration}" +%s)
				sleep_seconds=$((target_epoch - current_epoch))
				sleep $sleep_seconds
			else
				# We can set the wallpaper.
				((COUNTER = COUNTER + 1))
				echo "$(date) ${COUNTER}/${#array[@]}: $img"
				$setter "$img"
				sleep $frequency
			fi
		else
			# Do not run this day.
			echo "This is the weekend"
			current_epoch=$(date +%s)
			target_epoch=$(date -d "tomorrow" +%s)
			sleep_seconds=$((target_epoch - current_epoch))
			sleep $sleep_seconds
		fi
	done
done
