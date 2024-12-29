#!/bin/bash

LOG_LEVEL_ERROR=0
LOG_LEVEL_WARN=1
LOG_LEVEL_INFO=2
LOG_LEVEL_DEBUG=3
# set default log level to info
current_log_level=$LOG_LEVEL_INFO

BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
GREY=$(tput setaf 8)
RESET=$(tput sgr0)

init_log() {
    current_log_level=$1
    # in CI environment, TERM env var might not set
    if [ -z "${TERM}" ]; then
        echo "[INFO] TERM=${TERM} is empty(CI=${CI}). Setting TERM to xterm-color"
        export TERM="xterm-color"
    fi
}

log() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    if [ "$level" -le $current_log_level ]; then
        case $level in
        "$LOG_LEVEL_ERROR") echo "${BOLD}${RED}[$timestamp][ERROR] $message${RESET}" >&2 ;;
        "$LOG_LEVEL_WARN") echo "${BOLD}${YELLOW}[$timestamp][WARN] $message${RESET}" >&2 ;;
        "$LOG_LEVEL_INFO") echo "${BOLD}[$timestamp][INFO] $message${RESET}" ;;
        "$LOG_LEVEL_DEBUG") echo "${GREY}[$timestamp][DEBUG] $message${RESET}" ;;
        *) echo "[$timestamp](invalid level) $message" >&2 ;;
        esac
    fi
}

echo_green() {
    echo "${GREEN}$1${RESET}"
}

echo_blue() {
    echo "${BLUE}$1${RESET}"
}
