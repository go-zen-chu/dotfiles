#!/bin/bash

set -eu

check_os() {
    local os
    os=$(uname -s)

    case "${os}" in
    "Darwin")
        os="macos"
        ;;
    "Linux")
        if [ -f /etc/lsb-release ]; then
            os="ubuntu"
        else
            os="unsupported linux"
        fi
        ;;
    *)
        os="unsupported: ${os}"
        ;;
    esac
    echo "${os}"
}

check_cpu_arch() {
    uname -m
}

check_current_user() {
    whoami
}

check_ci() {
    if [[ -n "${CI-}" ]]; then
        echo "true"
    else
        echo "false"
    fi
}