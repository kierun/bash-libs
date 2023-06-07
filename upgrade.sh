#!/bin/bash
# Nifty colours.
#
# Colours for echo commands.
# For colour codes, see https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
error=$(tput setaf 9)   # bright red.
success=$(tput setaf 2) # normal green.
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
    for ((i = len - offset + 1; i < cols; i++)); do printf "_"; done
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

# pipx for Python.
header "\ue73c Pipx update" 6
echo ""
pipx upgrade-all

# Cargo for Rust.
header "\ue7a8 Cargo update" 6
echo ""
echo "You need to run: cargo install cargo-update"
cargo install-update -a

# Root kits?
header "\u2620 Rootkit" 6
echo ""
if sudo chkrootkit 2>&1 | tee ~/.chkrootkit.log | grep -v grep | grep INFECTED; then
    echo "${error}""💀💀💀💀💀💀💀💀💀💀 We MIGHT have had a problem!""${reset}"
    echo "${error}""Now is a good time to check ~/.chkrootkit.log!""${reset}"
else
    echo "${success}""Chkrootkit has not found any rootkits. Good.""${reset}"
fi
