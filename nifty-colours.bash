#!/bin/bash
# Script to reset passwords for Worldr default users.

# Nifty colours.
#
# Colours for echo commands.
# For colour codes, see https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
error=$(tput setaf 9)     # bright red.
success=$(tput setaf 2)   # normal green.
warning=$(tput setaf 214) # orange.
info=$(tput setaf 99)     # purple.
header=$(tput setaf 69)   # light blue.
debug=$(tput setaf 240)   # grey.
reset=$(tput sgr0)

header() {
    offset=$2
    title="___/ $1 \\"
    len=${#title}
    cols=$(tput cols)
    echo -en "${header}"
    echo -en "    "
    for ((i = 4; i < len - offset; i++)); do printf "_"; done
    echo
    echo -en "$title"
    for ((i = len; i < cols; i++)); do printf "_"; done
    echo
    echo -en "${reset}"
}

header "\uebc7  Nifty colours and header…" 6
echo "${error}error.${reset}"
echo "${success}success.${reset}"
echo "${warning}warning.${reset}"
echo "${info}info.${reset}"
echo "${debug}debug.${reset}"
