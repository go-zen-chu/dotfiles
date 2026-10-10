#!/bin/bash

# shellcheck disable=SC2154 # os and is_ci are set by install.sh, which sources this file
set -eu

linux_setup_basic_tools() {
    echo_blue "Setup basic tools for linux..."

    brew_install xclip
    brew_install keychain
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

    linux_setup_google_chrome

    # google-cloud-sdk
    if hash gcloud 2>/dev/null; then
        log "$LOG_LEVEL_INFO" "[✓] google-cloud-sdk is already installed"
    else
        log "$LOG_LEVEL_INFO" "[ ] google-cloud-sdk not installed. Installing..."
        case "${os}" in
        "ubuntu")
            sudo snap install google-cloud-cli --classic
            gcloud init --skip-diagnostics
            log "$LOG_LEVEL_INFO" "[✓] google-cloud-sdk install finished"
            ;;
        *)
            log "$LOG_LEVEL_WARN" "skip google-cloud-sdk install for ${os} because it is not supported"
            ;;
        esac
    fi
}

linux_setup_google_chrome() {
    if hash google-chrome 2>/dev/null; then
        log "$LOG_LEVEL_INFO" "[✓] google-chrome is already installed"
        return
    fi
    # TIPS: installing a GUI browser is not needed in CI
    if [ "${is_ci}" = "true" ]; then
        log "$LOG_LEVEL_INFO" "skip google-chrome install for CI"
        return
    fi
    # on WSL, use Chrome installed on the Windows side (os-windows/setup.ps1)
    if grep -qi microsoft /proc/version 2>/dev/null; then
        log "$LOG_LEVEL_INFO" "skip google-chrome install for WSL"
        return
    fi
    # google only provides amd64 .deb packages
    if [ "$(check_cpu_arch)" != "x86_64" ]; then
        log "$LOG_LEVEL_WARN" "skip google-chrome install for $(check_cpu_arch) because it is not supported"
        return
    fi

    case "${os}" in
    "ubuntu")
        log "$LOG_LEVEL_INFO" "[ ] google-chrome not installed. Installing..."
        local deb_path
        deb_path="$(mktemp -d)/google-chrome-stable_current_amd64.deb"
        # the package also registers google's apt repository for updates
        curl -fsSL -o "${deb_path}" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        if [ "${linux_package_list_updated}" = "false" ]; then
            sudo apt-get update
            linux_package_list_updated="true"
        fi
        sudo apt-get install -y "${deb_path}"
        rm -f "${deb_path}"
        log "$LOG_LEVEL_INFO" "[✓] google-chrome install finished"
        ;;
    *)
        log "$LOG_LEVEL_WARN" "skip google-chrome install for ${os} because it is not supported"
        ;;
    esac
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
    *)
        log "$LOG_LEVEL_ERROR" "skip package install for ${os} because it is not supported"
        ;;
    esac
}
