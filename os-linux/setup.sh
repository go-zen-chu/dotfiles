#!/bin/bash

set -eu

linux_setup_basic_tools() {
    echo_blue "Setup basic tools for linux..."

    brew_install xclip
}

linux_setup_personal_machine_tools() {
    echo_blue "Setup personal machine tools for linux..."

    # tailscale
    if hash tailscale 2>/dev/null; then
        log "$LOG_LEVEL_INFO" "[✓] tailscale is already installed"
    else
        log "$LOG_LEVEL_INFO" "[ ] tailscale not installed. Installing..."
        curl -fsSL https://tailscale.com/install.sh | sh
        log "$LOG_LEVEL_INFO" "[✓] tailscale install finished"
        echo_green "run 'sudo tailscale up' for joining to tailscale network"
    fi

    # xdg-open requred for tmux-plugin tmux-open
    if hash xdg-open 2>/dev/null; then
        log "$LOG_LEVEL_INFO" "[✓] xdg-utils is already installed"
    else
        log "$LOG_LEVEL_INFO" "[ ] xdg-utils not installed. Installing..."
        linux_package_install "xdg-utils"
        log "$LOG_LEVEL_INFO" "[✓] xdg-utils install finished"
    fi
}

linux_package_list_updated="false"

linux_package_install() {
    local package_name
    package_name=$1

    case "${os}" in
    "ubuntu")
        if [ "${linux_package_list_updated}" = "false" ]; then
            sudo apt-get update
            linux_package_list_updated="true"
        fi
        sudo apt-get install -y "${package_name}"
        ;;
    "*")
        log "$LOG_LEVEL_ERROR" "skip package install for ${os} because it is not supported"
        ;;
    esac
}
