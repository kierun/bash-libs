#!/bin/bash
# Nifty colours.
#
# Colours for echo commands.
# For colour codes, see https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
# error=$(tput setaf 9)     # bright red.
# success=$(tput setaf 2)   # normal green.
# warning=$(tput setaf 214) # orange.
info=$(tput setaf 99)   # purple.
header=$(tput setaf 69) # light blue.
# debug=$(tput setaf 240) # grey.
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

# This is only for Fedora.
if test -e /etc/fedora-release; then
    header "\uf30a  Fedora" 6

    echo -e "\n""${info}""DNF update""${reset}"
    sudo dnf up

    echo -e "\n""${info}""Fltapak""${reset}"
    flatpak update
fi

# This is only for Ubuntu.
if test -e "/etc/debian_version"; then
    header "\uebc9  Debian" 6

    echo -e "\n""${info}""APT update and upgrade""${reset}"
    sudo apt update && sudo apt upgrade
fi

# This is for everything!
header "\ue73c Pipx" 6
echo ""
pipx upgrade-all
