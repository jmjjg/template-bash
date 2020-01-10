#!/usr/bin/env bash

# "Library"
# ---------

set -o errexit
set -o nounset
set -o pipefail

# Internal constants

declare -r _blue_="\e[34m"
declare -r _cyan_="\e[36m"
declare -r _default_="\e[0m"
declare -r _green_="\e[32m"
declare -r _red_="\e[31m"

# Bootstrap

if [ "`getopt --longoptions debug,help -- dh "$@" 2> /dev/null | grep "\(\d\|\-\-debug\)"`" != "" ] ; then
    declare -r __DEBUG__=1
    set -o xtrace
else
    declare -r __DEBUG__=0
fi

declare -r __PID__="${$}"

declare -r __FILE__="$(realpath "${0}")"
declare -r __SCRIPT__="$(basename "${__FILE__}")"
declare -r __ROOT__="$(realpath "$(dirname "${__FILE__}")")"

printf "${_cyan_}Startup:${_default_} started process ${__PID__}\n\n"

# Error and exit handling: exit is trapped, as well as signals.
# If a __cleanup__ function exists, it will be called on signal or exit and the exit code will be passed as parameter.

__trap_signals__()
{
    local code="${?}"
    local signal=$((${code} - 128))
    local name="`kill -l ${signal}`"

    printf >&2 "\nProcess ${__PID__} received SIG${name} (${signal}), exiting..."
}

__trap_exit__()
{
    local code="${?}"

    if [ ${code} -eq 0 ] ; then
        printf "\n${_green_}Success:${_default_} process ${__PID__} exited normally\n"
    else
        printf >&2 "\n${_red_}Error:${_default_} process ${__PID__} exited with error code ${code}\n"
    fi

    # @todo: no cleanup should be done for SIGQUIT ?
    if [ "`type -t __cleanup__`" = "function" ] ; then
        __cleanup__
    fi
}

trap "__trap_signals__" SIGHUP SIGINT SIGQUIT SIGTERM
trap "__trap_exit__" EXIT

# Custom code
# -----------

# Usage function

__usage__()
{
    printf "NAME\n"
    printf "  %s\n" "$__SCRIPT__"
    printf "\nDESCRIPTION\n"
    printf "  <description>\n"
    printf "\nSYNOPSIS\n"
    printf "  %s [OPTION]...\n" "$__SCRIPT__"
    # printf "  %s [OPTION]... [COMMAND]\n" "$__SCRIPT__"
    # printf "\nCOMMANDS\n"
    # printf "  <name>\t<description>\n"
    printf "\nOPTIONS\n"
    printf "  -d|--debug\t<description> (set -o xtrace)\n"
    printf "  -h|--help\t<description>\n"
    printf "\nEXEMPLES\n"
    printf "  %s -h\n" "$__SCRIPT__"
}

# Main function

__main__()
{
    (
        # Options
        opts=$(getopt --longoptions debug,help -- dh "$@") || (__usage__ >&2 ; exit 1)
        eval set -- "$opts"
        while true; do
            case "${1}" in
                -d|--debug)
                    shift
                    ;;
                -h|--help)
                    __usage__
                    exit 0
                    ;;
                --)
                    shift
                    break
                    ;;
            esac
        done

        # Commands
        case "${1:-}" in
            --|*)
                >&2 __usage__
                exit 1
            ;;
        esac

        exit 0
    )
}

__main__ "$@"
