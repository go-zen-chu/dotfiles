#!/bin/bash

set -eu

source ./scripts/log.sh
source ./scripts/env.sh

os=""

startup() {
    log "$LOG_LEVEL_INFO" "Start dotfile install script"
    cmdname=$(basename "$0")
    flg_verbose="false"

    while getopts v OPT; do
        case $OPT in
        "v") flg_verbose="true" ;;
        *)
            echo "Usage: $cmdname [-v (verbose)]" 1>&2
            exit 0
            ;;
        esac
    done

    if [ "$flg_verbose" = "true" ]; then
        init_log "$LOG_LEVEL_DEBUG"
    else
        init_log "$LOG_LEVEL_INFO"
    fi

    check_env
    if [[ "${os}" == unsupported* ]]; then
        log "$LOG_LEVEL_ERROR" "Unsupported OS: ${os}"
        exit 1
    fi
}

check_env() {
    os=$(check_os)
    echo "OS: ${os}"
    echo "CPU: $(check_cpu_arch)"
    echo "USER: $(check_current_user)"
}

startup
