#!/bin/bash

# shellcheck disable=SC2154 # os and is_ci are set by install.sh, which sources this file
set -eu

# Homebrew does not support termux (Android), so tools are installed with pkg instead.
# install.sh calls brew_install for every tool and it is redirected to termux_pkg_install.

# map a Homebrew formula name to a termux package name.
# empty means the tool is not available on termux.
termux_pkg_name() {
    case "$1" in
    "go") echo "golang" ;;
    node@*) echo "nodejs-lts" ;;
    # kind needs docker, krew has no android build
    "kind" | "krew") echo "" ;;
    # installed by setup_claude_code
    "claude-code") echo "" ;;
    "sass/sass/sass") echo "" ;;
    *) echo "$1" ;;
    esac
}

termux_pkg_install() {
    local formula_name=$1
    local package_name
    package_name=$(termux_pkg_name "${formula_name}")

    if [ -z "${package_name}" ]; then
        log "$LOG_LEVEL_INFO" "skip ${formula_name} install because it is not available on termux"
        return
    fi
    if dpkg -s "${package_name}" >/dev/null 2>&1; then
        log "$LOG_LEVEL_INFO" "[✓] ${package_name} installed (termux)"
        return
    fi
    log "$LOG_LEVEL_INFO" "[ ] ${package_name} not installed (termux). Installing..."
    # some packages may not be provided in the termux repository, so keep going on failure
    if pkg install -y "${package_name}"; then
        log "$LOG_LEVEL_INFO" "[✓] ${package_name} install finished"
    else
        log "$LOG_LEVEL_WARN" "failed to install ${package_name} with pkg"
    fi
}

termux_setup_package_manager() {
    echo_blue "Setup package manager for termux..."

    if ! hash pkg 2>/dev/null; then
        log "$LOG_LEVEL_ERROR" "pkg command not found"
        exit 1
    fi
    log "$LOG_LEVEL_INFO" "[✓] pkg installed"
}

termux_setup_basic_tools() {
    echo_blue "Setup basic tools for termux..."

    # tput, clear
    termux_pkg_install ncurses-utils
    # ssh-agent / ssh-add, git commit signing
    termux_pkg_install openssh
    # termux-clipboard-set (needs the Termux:API app)
    termux_pkg_install termux-api
}

termux_setup_personal_machine_tools() {
    echo_blue "Setup personal machine tools for termux..."

    log "$LOG_LEVEL_INFO" "no termux specific personal machine tools"
}
