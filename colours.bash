#!/bin/bash

tput init

end=$(($(tput colors) - 1))
w=8
for c in $(seq 0 $end); do
	eval "$(printf "tput setaf %3s   " "$c")"
	printf "%5s ■⏺  " "$c"
	[[ $c -ge $((w * 2)) ]] && offset=2 || offset=0
	[[ $(((c + offset) % (w - offset))) -eq $(((w - offset) - 1)) ]] && echo
done

tput init
