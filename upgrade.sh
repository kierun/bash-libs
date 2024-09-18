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
REGEXP=".*"     # Everything by default.
COLOR="#444444" # This grey works for me.

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

# Check that https://github.com/BurntSushi/ripgrep is installed.
if ! [ -x "$(command -v rg)" ]; then
    echo 'Error: RipGrep is not installed. Please install it.' >&2
    exit 1
fi

# This is only for Fedora.
if [[ $(lsb_release -is) == "Fedora" ]]; then
    header "\uf30a  Fedora" 6

    echo -e "\n""${info}""DNF update""${reset}"
    if command -v dnf5 &>/dev/null; then
        # sudo dnf5 up | colout "$REGEXP" "$COLOR"
        sudo dnf5 up
    else
        # sudo dnf up | colout "$REGEXP" "$COLOR"
        sudo dnf up
    fi

    echo -e "\n""${info}""Fltapak""${reset}"
    # sudo flatpak update | colout "$REGEXP" "$COLOR"
    sudo flatpak update
fi

# This is only for Ubuntu.
if [[ $(lsb_release -is) == "Ubuntu" ]]; then
    header "\uebc9  Ubuntu" 6

    echo -e "\n""${info}""APT update and upgrade""${reset}"
    # sudo apt update | colout "$REGEXP" "$COLOR" && sudo apt upgrade | colout "$REGEXP" "$COLOR"
    sudo apt update && sudo apt upgrade
fi

# SPAM!
if [[ $(lsb_release -is) == "Ubuntu" ]]; then
    header "\ue7a8  SPAM update" 6
    last_date=$(date +%Y-%m-%d -d '7 day ago')
    echo "${info}Learning HAM from last ${last_date} days${reset}"
    # This command works as it is. Word splitting is not happening.
    # shellcheck disable=SC2046
    sudo sa-learn --ham --showdots $(find "$HOME"/Maildir/.[a-z]*/cur/* -newermt "${last_date}" -type f -print) | colout "$REGEXP" "$COLOR"
    echo "${info}Learning SPAM${reset}"
    sudo sa-learn --spam --showdots "$HOME"/Maildir/.Spam/cur/* | colout "$REGEXP" "$COLOR"
    echo "${info}Running spamassassin update, restating iff it is necessary.${reset}"
    sudo sa-update -v && sudo service spamassassin restart
    echo "${info}Removing spam old than 28 days.${reset}"
    find "${HOME}"/Maildir/.Spam/cur/* -mtime +28 -print -type f -delete | wc -l | colout "$REGEXP" "$COLOR"
fi

# This is for everything!

# pipx for Python.
header "\ue73c Pipx update" 6
echo ""
pipx upgrade-all 2>&1 | colout "$REGEXP" "$COLOR"
pipx list --short | colout "$REGEXP" "$COLOR"

# Rust then Cargo.
if command -v rustup &>/dev/null; then
    header "\ue7a8 Rust update" 6
    rustup update | colout "$REGEXP" "$COLOR"
fi
header "\ue7a8 Cargo update" 6
echo ""
if ! cargo install-update -a | colout "$REGEXP" "$COLOR"; then
    # https://github.com/matthiaskrgr/cargo-cache
    echo "${error}""You need to run: cargo install cargo-update""${reset}"
else
    cargo cache --autoclean | colout "$REGEXP" "$COLOR"
fi

# ClamAV
header "\ue214 ClamAV update" 6
echo ""
if [[ $(lsb_release -is) == "Ubuntu" ]]; then
    sudo /etc/init.d/clamav-freshclam stop | colout "$REGEXP" "$COLOR"
fi
if ! sudo /usr/bin/freshclam | colout "$REGEXP" "$COLOR"; then
    echo "${error}""💀 clamAV not updated.""${reset}"
else
    echo "${success}""clamAV updated.""${reset}"
fi
if [[ $(lsb_release -is) == "Ubuntu" ]]; then
    sudo /etc/init.d/clamav-freshclam start | colout "$REGEXP" "$COLOR"
fi

# Golang.
header "\ue724 Golang update" 6
echo ""
if command -v go-global-update &>/dev/null; then
    if go-global-update | colout "$REGEXP" "$COLOR"; then
        echo "${success}""Golang things were updated.""${reset}"
    fi
else
    echo "${error}""💀 go-global-update not found: go install github.com/Gelio/go-global-update@latest""${reset}"
fi
#
# # Root kits?
# header "\u2620 Rootkit" 6
# sleep 3
# echo ""
# if sudo /usr/bin/chkrootkit 2>&1 | tee ~/.chkrootkit.log | rg -v rg | rg INFECTED; then
#     echo "${error}""💀💀💀💀💀💀💀💀💀💀 We MIGHT have had a problem!""${reset}"
#     echo "${error}""Now is a good time to check ~/.chkrootkit.log!""${reset}"
# else
#     echo "${success}""Chkrootkit has not found any rootkits. Good.""${reset}"
# fi
