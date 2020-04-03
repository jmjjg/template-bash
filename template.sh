#!/usr/bin/env bash

# ======================================================================================================================
# "Library"
# ======================================================================================================================

set -o errexit
set -o nounset
set -o pipefail

# ----------------------------------------------------------------------------------------------------------------------
# Internal constants
# ----------------------------------------------------------------------------------------------------------------------

declare -r _blue_="\e[34m"
declare -r _cyan_="\e[36m"
declare -r _default_="\e[0m"
declare -r _grey_="\e[90m"
declare -r _green_="\e[32m"
declare -r _red_="\e[31m"
declare -r _yellow_="\e[93m"
declare -r _bg_red_="\e[41m"

# ----------------------------------------------------------------------------------------------------------------------
# Bootstrap
# ----------------------------------------------------------------------------------------------------------------------

if [ "$(getopt --longoptions xtrace -- x "$@" 2> /dev/null | grep --color=none "\(^\|\s\)\(\-x\|\-\-xtrace\)\($\|\s\)")" != "" ]; then
    declare -r __XTRACE__=1
    set -o xtrace
else
    declare -r __XTRACE__=0
fi

declare -r __PID__="${$}"

declare -r __FILE__="$(realpath "${0}")"
declare -r __SCRIPT__="$(basename "${__FILE__}")"
declare -r __ROOT__="$(realpath "$(dirname "${__FILE__}")")"

# ======================================================================================================================
# @todo: put in "Library"
# ======================================================================================================================

_timestamp_() {
    date +'%Y-%m-%d %H:%M:%S'
}

_log_() {
    local timestamp="$(_timestamp_)"
    local level="${1}"
    local message="${2}"
    local color

    case "${level}" in
        CRITICAL) color="${_bg_red_}" ;;
        DEBUG) color="${_grey_}" ;;
        ERROR) color="${_red_}" ;;
        INFO) color="${_cyan_}" ;;
        WARNING) color="${_yellow_}" ;;
        --|*) level="CRITICAL" ; color="${_bg_red_}" ;;
    esac

    printf "${timestamp} ${color}%-8s${_default_} ${message}\n" "${level}"
}

_log_critical_() {
    >&2 _log_  "CRITICAL" "${1}"
}

_log_debug_() {
    _log_  "DEBUG" "${1}"
}

_log_error_() {
    >&2 _log_  "ERROR" "${1}"
}

_log_info_() {
    _log_  "INFO" "${1}"
}

_log_warning_() {
    _log_  "WARNING" "${1}"
}

# ----------------------------------------------------------------------------------------------------------------------

_safe_eval_() {
    local cmd="${1}"

    set +o errexit
    output=$(eval "${cmd}")
    exit=$?
    set -o errexit

    if [ ${exit} -ne 0 ]; then
        _log_error_ "${cmd} returned error code ${exit}"
        while read line ; do
            _log_error_ "${line}"
        done < <(echo "${output}")
    else
        echo "${output}"
    fi

    return ${exit}
}

# ----------------------------------------------------------------------------------------------------------------------
# Error and exit handling: exit is trapped, as well as signals.
# If a __cleanup__ function exists, it will be called on signal or exit and the exit code will be passed as parameter.
# ----------------------------------------------------------------------------------------------------------------------

__trap_signals__() {
    local code="${?}"
    local signal=$((${code} - 128))
    local name="$(kill -l ${signal})"

    _log_error_ "\nProcess ${__PID__} received SIG${name} (${signal}), exiting..."
}

__trap_exit__() {
    local code="${?}"

    if [ ${code} -eq 0 ]; then
        _log_debug_ "Process ${__PID__} exited normally"
    else
        _log_error_ "Process ${__PID__} exited with error code ${code}"
    fi

    # @todo: no cleanup should be done for SIGQUIT ?
    if [ "$(type -t __cleanup__)" = "function" ]; then
        __cleanup__
    fi
}

trap "__trap_signals__" SIGHUP SIGINT SIGQUIT SIGTERM
trap "__trap_exit__" EXIT

# ======================================================================================================================
# Custom code
# ======================================================================================================================

# ----------------------------------------------------------------------------------------------------------------------
# Usage function
# ----------------------------------------------------------------------------------------------------------------------

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
    printf "  -h|--help\tShow this help message\n"
    printf "  -x|--xtrace\tEnable xtrace\n"
    printf "\nEXEMPLES\n"
    printf "  %s -h\n" "$__SCRIPT__"
}

# ----------------------------------------------------------------------------------------------------------------------
# Main function
# ----------------------------------------------------------------------------------------------------------------------

__main__()
{
    (
        _log_debug_ "Started process ${__PID__}"

        # Options
        opts=$(getopt --longoptions help,xtrace -- hx "$@") || (__usage__ >&2 ; exit 1)
        eval set -- "$opts"
        while true; do
            case "${1}" in
                -h|--help)
                    __usage__
                    exit 0
                    ;;
                -x|--xtrace)
                    shift
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
