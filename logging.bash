#!/bin/bash
################################################################################
#
# Question: What does this do?
# Answer: It is a logging library for bash scripts
#
# Question: What does it look like?
# Answer: Have ". <path>/logging.bash" in your code where <path> is wherever you
# put this.
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

function __set_strict() {
	# Exit on error.
	# Trap exit.
	# This script is supposed to run in a subshell.
	# See also: http://fvue.nl/wiki/Bash:_Error_handling

	# Let shell functions inherit ERR trap.  Same as `set -E'.
	set -o errtrace
	# Trigger error when expanding unset variables.  Same as `set -u'.
	set -o nounset

	# and don't let pipes conceal errors
	set -o pipefail
}

function __trap_exit() {
	#  Trap non-normal exit signals: 1/HUP, 2/INT, 3/QUIT, 15/TERM, ERR
	#  NOTE1: - 9/KILL cannot be trapped.
	#         - 0/EXIT isn't trapped because:
	#           - with ERR trap defined, trap would be called twice on error
	#           - with ERR trap defined, syntax errors exit with status 0, not 2
	#  NOTE2: Setting ERR trap does implicit `set -o errexit' or `set -e'.
	trap onexit 1 2 3 15 ERR
}

#--- onexit() -----------------------------------------------------
#  @param $1 integer  (optional) Exit status.  If not set, use `$?'
function onexit() {
	local exit_status=${1:-$?}
	.log 6 Exiting "$0" with "$exit_status"
	exit "$exit_status"
}

# Logging with niffty 256 colours support on tty.

declare -A __LOG_LEVELS
declare -A __LOG_CLR_STRINGS
declare -A __LOG_CLR_VALUES

# notice and below
__LOG_LEVEL_MAX=5

__LOG_LEVELS=([0]="emergency"
	[1]="alert"
	[2]="critical"
	[3]="err"
	[4]="warning"
	[5]="notice"
	[6]="info"
	[7]="debug")

__LOG_CLR_VALUES=([0]=196
	[1]=161
	[2]=201
	[3]=126
	[4]=214
	[5]=87
	[6]=47 # was 252
	[7]=242)

# create our strings
for i in $(seq 0 7); do
	__LOG_CLR_STRINGS[$i]=$(tput setaf "${__LOG_CLR_VALUES[$i]}")
done
__LOG_CLR_RESET=$(tput sgr0)

__LOG_CLR_USE=1
__LOG_TS_CALLOUT=0
__LOG_EMERG_EXIT=0

# give the caller half a chance without having to read the code
function __logging_lib_help() {

	cat <<-EOF
		Calling: . skeleton.bash

		Command-line args:
		 -S              Strict mode - invokes some strict bash opts
		 -T              Call date for more accurate timestamps in log lines
		 -N              Switch off colour output to tty
		 -Q              Quiet - warns and below only
		 -V              Verbose - include info
		 -D              Debug - include debug, set $DEBUG
		 -X              Trap exit status and report it
		 -E              Calls to emergency exit the process

		This skeleton adds some logging and the command-line switches to control
		it.  It adds error trapping if desired (call onexit explicitly at the end
		of your script if you want the message).

		Below are some example log messages.  Try the timestamp and verbosity
		options with with.

	EOF

	## Do your things!
	.emerg "Panic."
	.alert "A snake."
	.crit "Oooh, it's a snake."
	.err "It's a..."
	.warn "Badgers"
	.notice "Badgers"
	.info "Badgers"
	.debug "Mushroom-mushroom!"
}

# defaults to notice
function .log() {

	local level=${1:-5}
	shift

	if [ $__LOG_LEVEL_MAX -lt "$level" ]; then
		return 0
	fi

	local ts=$SECONDS
	local lstr=${__LOG_LEVELS[$level]}

	# complex timestamps?
	if [ $__LOG_TS_CALLOUT -gt 0 ]; then
		local tstr
		tstr=$(date '+%F %T.%N')
		ts=${tstr:0:23}
	fi

	# just switch on the variable for now
	if [ $__LOG_CLR_USE -gt 0 ]; then
		echo "[$ts] [${__LOG_CLR_STRINGS[$level]}${lstr}${__LOG_CLR_RESET}]" "$@"
	else
		echo "[$ts] [$lstr]" "$@"
	fi
}

function .emerg() {
	.log 0 "$@"
	if [ $__LOG_EMERG_EXIT -gt 0 ]; then
		exit 1
	fi
}
function .alert() {
	.log 1 "$@"
}
function .crit() {
	.log 2 "$@"
}
function .err() {
	.log 3 "$@"
}
function .warn() {
	.log 4 "$@"
}
function .notice() {
	.log 5 "$@"
}
function .info() {
	.log 6 "$@"
}
function .debug() {
	.log 7 "$@"
}

#################################################################################
# MY SCRIPT FOLLOWS

## Command line options.
OPTIND=1 # Reset in case getopts has been used previously in the shell.

__prev_opterr=$OPTERR
OPTERR=0
while getopts "HSVDTMNXEQ" opt; do
	case $opt in
	S)
		__set_strict
		;;
	V)
		__LOG_LEVEL_MAX=6
		;;
	D)
		__LOG_LEVEL_MAX=7
		DEBUG=1
		;;
	Q)
		__LOG_LEVEL_MAX=4
		;;
	T)
		__LOG_TS_CALLOUT=1
		;;
	N)
		__LOG_CLR_USE=0
		;;
	X)
		__trap_exit
		;;
	E)
		__LOG_EMERG_EXIT=1
		;;
	# do nothing to other people's args
	*) ;;
	esac
done

# fix optind and opterr
OPTIND=1
OPTERR=$__prev_opterr

# detect a non-tty
if [ ! -t 1 ]; then
	__LOG_CLR_USE=0
fi

# capture bash seconds if we need to
if [ $__LOG_TS_CALLOUT -eq 0 ]; then
	SECONDS=$(date +%s)
fi

# are we being included?
this=$(realpath "${BASH_SOURCE[@]}")
orig=$(realpath "$0")

if [ "$this" == "$orig" ]; then
	__logging_lib_help
fi
