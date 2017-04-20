#!/bin/bash
################################################################################
#
# Question: What does this do?
# Answer: It is a skeleton for an over engineered bash script. ☺
#
# Question: What does it look like?
# Answer:  run it `./skeleton.bash -v 7` and see…
#
################################################################################
# Copyright (C) 2017 Yann Golanski.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#################################################################################
# Exit on error.
# Trap exit.
# This script is supposed to run in a subshell.
# See also: http://fvue.nl/wiki/Bash:_Error_handling
# Let shell functions inherit ERR trap.  Same as `set -E'.
set -o errtrace 
# Trigger error when expanding unset variables.  Same as `set -u'.
set -o nounset
#  Trap non-normal exit signals: 1/HUP, 2/INT, 3/QUIT, 15/TERM, ERR
#  NOTE1: - 9/KILL cannot be trapped.
#         - 0/EXIT isn't trapped because:
#           - with ERR trap defined, trap would be called twice on error
#           - with ERR trap defined, syntax errors exit with status 0, not 2
#  NOTE2: Setting ERR trap does implicit `set -o errexit' or `set -e'.
trap onexit 1 2 3 15 ERR
#--- onexit() -----------------------------------------------------
#  @param $1 integer  (optional) Exit status.  If not set, use `$?'
function onexit() {
    local exit_status=${1:-$?}
    .log 6 Exiting $0 with $exit_status
    exit $exit_status
}

# Logging with niffty 256 colours support on tty.
__VERBOSE=0
declare -A LOG_LEVELS
LOG_LEVELS=([0]="emergency"
            [1]="alert"
            [2]="critical"
            [3]="err"
            [4]="warning"
            [5]="notice"
            [6]="info"
            [7]="debug")
reset=`tput sgr0`
LOG_COLOURS=([0]=`tput setaf 196`
             [1]=`tput setaf 161`
             [2]=`tput setaf 201`
             [3]=`tput setaf 126`
             [4]=`tput setaf 214`
             [5]=`tput setaf 87`
             [6]=`tput setaf 252` 
             [7]=`tput setaf 242`)

function .log () {
  local LEVEL=${1}
  shift
  if [ -t 1 ]
  then 
    # Terminal.
    if [ ${__VERBOSE} -ge ${LEVEL} ]; then
      echo "${LOG_COLOURS[$LEVEL]}[${LOG_LEVELS[$LEVEL]}] $@ ${reset}"
    fi
  else
    # Not a terminal.
    if [ ${__VERBOSE} -ge ${LEVEL} ]; then
      echo "[${LOG_LEVELS[$LEVEL]}]" "$@"
    fi
  fi
}

#################################################################################
# MY SCRIPT FOLLOWS

## Command line options.
OPTIND=1 # Reset in case getopts has been used previously in the shell.
while getopts "hv:" opt; do
    case "$opt" in
    h)
        echo "Backup a remote database locally."
        echo ""
        echo "Supported options are:"
        echo "  h       This help."
        echo "  v NBR   Verbosity from 0 (emergency) to 7 (debug)."
        echo ""
        exit 0
        ;;
    v) __VERBOSE=$OPTARG
        ;;
    *) echo "Command is not supported."
       exit 1
        ;;
    esac
done
shift $((OPTIND-1))


## Do your things!

.log 0 "This is a ${LOG_LEVELS[0]} message."
.log 1 "This is a ${LOG_LEVELS[1]} message."
.log 2 "This is a ${LOG_LEVELS[2]} message."
.log 3 "This is a ${LOG_LEVELS[3]} message."
.log 4 "This is a ${LOG_LEVELS[4]} message."
.log 5 "This is a ${LOG_LEVELS[5]} message."
.log 6 "This is a ${LOG_LEVELS[6]} message."
.log 7 "This is a ${LOG_LEVELS[7]} message."
 
#################################################################################
# Always call `onexit' at end of script
onexit
# EOF
