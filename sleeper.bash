__SLPCUSEC=0
__SLPIUSEC=1000000
__SLPIMAX=60000000
__SLPNEXT=0
__SLPINTV=''
__SLPUSEC=0
__SLPLOOP=1
__SLPBEFORE=0
__SLPSTARTED=0


function __sleeper_lib_help( ) {
    cat <<- EOF
Calling: . <path>/sleeper.bash

There are no command-line options for the sleeper library - call
the sleeper control functions explicitly.

More docs due here.
EOF

    exit 0
}


# detect systems which don't have usleep
us=$(which usleep)
if [ -z "$us" ]; then
    # yes, debian
    function usleep( ) {
        stime=$(echo "$__SLPUSEC / 1000000" | bc -l)
        sleep $stime
    }
fi

function __sleeper_set_usec_time( ) {
    str=$(date +%S.%N)
    str=${str/%[0-9][0-9][0-9]/}
    str=${str/\./}
    while [ ${str:0:1} == '0' ]; do
        str=${str:1}
    done
    if [ -z "$str" ]; then
        str='0'
    fi
    __SLPCUSEC=$str
}


function sleeper_start( ) {

    __SLPSTARTED=1

    # grab an initial time
    __sleeper_set_usec_time
    __SLPNEXT=$((($__SLPCUSEC + $__SLPIUSEC) % $__SLPIMAX))
}


function sleeper_set_interval( ) {

    __SLPINTV=$1
    __SLPIUSEC=$(echo "1000000 * $__SLPINTV" | bc -l)
    __SLPIUSEC=${__SLPIUSEC%%.*}

    if [ $__SLPIUSEC -ge $__SLPIMAX ]; then
        # do we have the logging library?
        local lt=$(type -t .err)
        if [ "$lt" == "function" ]; then
            .err "Cannot handle interval $__SLPINTV - must be < 60 sec."
        else
            echo "Cannot handle interval $__SLPINTV - must be < 60 sec."
        fi
        return 1
    fi

    sleeper_start
}


function sleeper_sleep( ) {

    # get the current time
    __sleeper_set_usec_time
    __SLPUSEC=$(($__SLPNEXT - $__SLPCUSEC))
    __SLPNEXT=$((($__SLPNEXT + $__SLPIUSEC) % $__SLPIMAX))

    # correct for minute rollover
    if [ $__SLPUSEC -lt 0 ]; then
        __SLPUSEC=$(($__SLPUSEC + $__SLPIMAX))
    fi

    usleep $__SLPUSEC
}


function sleeper_set_sleep_before( ) {
    __SLPBEFORE=1
}

# exit from the loop
function sleeper_stop( ) {
    __SLPLOOP=0
}

# run some function you provide in a loop
function sleeper_loop( ) {

    run=$@

    trap sleeper_stop SIGINT SIGTERM SIGSTOP

    if [ $__SLPSTARTED -eq 0 ]; then
        sleeper_start
    fi

    if [ $__SLPBEFORE -eq 0 ]; then

        while [ $__SLPLOOP -gt 0 ]; do
            $run
            sleeper_sleep
        done

    else

        while [ $__SLPLOOP -gt 0 ]; do
            sleeper_sleep
            $run
        done

    fi
}

this=$(realpath $BASH_SOURCE)
orig=$(realpath $0)

if [ $this == $orig ]; then
    __sleeper_lib_help
fi
