#!/bin/bash

# Nifty colours and logging.
red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
orange=$(tput setaf 3)
reset=$(tput sgr0)

function lpr_warn {
    echo "${orange}""⚠  ""$1""${reset}"
}

function lpr_success {
    echo "${green}""√ ""$1""${reset}"
}

function lpr_failure {
    echo "${red}""✗ ""$1""${reset}"
}

function lpr_info {
    echo "${blue}""$1""${reset}"
}

# Check the last exit status and either print a all fine or bomb out.
function check_status {
    if [ "$1" -eq 0 ]
    then
        lpr_success "$2"
    else
        lpr_failure "[status $1] $2"
        exit "$1"
    fi
}

## Run a command and check its status.
function run_cmd {
    str="$1"
    shift
    "$@"
    local status=$?
    if (( status != 0 )); then
        lpr_failure "${str} error with $1" >&2
    else
        lpr_success "${str} successful"
    fi
    return $status
}

# A silly spinner.
## spinner takes the pid of the process as the first argument and
#  string to display as second argument (default provided) and spins
#  until the process completes.
function spinner() {
    local PROC="$1"
    local str="${2:-'☆testing 1 2 3 4 …'}"
    local delay="0.1"
    tput civis  # hide cursor
    printf "\033[1;34m"
    while [ -d "/proc/$PROC" ]; do
        printf "${blue}"'\033[s\033[u ⣾ %s\033[u' "$str" "${reset}"; sleep "$delay"
        printf "${blue}"'\033[s\033[u ⣽ %s\033[u' "$str" "${reset}"; sleep "$delay"
        printf "${blue}"'\033[s\033[u ⣻ %s\033[u' "$str" "${reset}"; sleep "$delay"
        printf "${blue}"'\033[s\033[u ⢿ %s\033[u' "$str" "${reset}"; sleep "$delay"
        printf "${blue}"'\033[s\033[u ⡿ %s\033[u' "$str" "${reset}"; sleep "$delay"
        printf "${blue}"'\033[s\033[u ⣟ %s\033[u' "$str" "${reset}"; sleep "$delay"
        printf "${blue}"'\033[s\033[u ⣯ %s\033[u' "$str" "${reset}"; sleep "$delay"
        printf "${blue}"'\033[s\033[u ⣷ %s\033[u' "$str" "${reset}"; sleep "$delay"
    done
    printf '\033[s\033[u%*s\033[u\033[0m' $((${#str}+6)) " "  # return to normal
    tput cnorm  # restore cursor
    return 0
}

# Get whatever terminal emulator one is using.
function get_terminal {
    terminal=$(xprop -id "$(xprop -root _NET_ACTIVE_WINDOW | \
            cut -d ' ' -f 5)" WM_CLASS | \
            awk -F '"' '{print $2}' | \
        tr '[:upper:]' '[:lower:]')
    command -v "$terminal"
}
