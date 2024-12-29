#!/bin/bash

set -eu

source ./scripts/log.sh
source ./scripts/env.sh

flg_verbose="false"
flg_personal_mode="false"

log_level=$LOG_LEVEL_INFO
os=""
is_ci="false"

homebrew_bin_path="/opt/homebrew/bin"

startup() {
    log "$LOG_LEVEL_INFO" "Start dotfile install script"
    cmdname=$(basename "$0")

    local OPTIND
    while getopts "vp" opt; do
        case $opt in
        "v") flg_verbose="true" ;;
        "p")
            flg_personal_mode="true"
            echo "flag personal"
            ;;
        *)
            echo "Usage: $cmdname [-v (verbose)] [-p (personal mode)]" 1>&2
            exit 0
            ;;
        esac
    done

    if [ "$flg_verbose" = "true" ]; then
        log_level=$LOG_LEVEL_DEBUG
    else
        log_level=$LOG_LEVEL_INFO
    fi
    init_log "$log_level"

    check_env

    if [[ "${os}" == unsupported* ]]; then
        log "$LOG_LEVEL_ERROR" "Unsupported OS: ${os}"
        exit 1
    fi
}

check_env() {
    echo_blue "Checking environment..."

    os=$(check_os)
    echo "OS         : ${os}"
    echo "CPU        : $(check_cpu_arch)"
    echo "User       : $(check_current_user)"
    echo "Is CI      : $(check_ci)"
    echo "Log level  : $(get_log_level "$log_level")"
}

setup_package_manager() {
    echo_blue "Setup package manager..."

    if ! hash brew 2>/dev/null; then
        log "$LOG_LEVEL_INFO" "[ ] Homebrew not installed. Installing..."
        if [ "$is_ci" = "true" ]; then
            export NONINTERACTIVE=1
        fi
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        export PATH=$homebrew_bin_path:$PATH

        unset NONINTERACTIVE
        brew update
    else
        log "$LOG_LEVEL_INFO" "[✓] Homebrew installed"
    fi
}

brew_install() {
    if [ ! -f "$homebrew_bin_path/$1" ] 2>/dev/null; then
        log "$LOG_LEVEL_INFO" "[ ] $1 not installed (homebrew). Installing..."
        brew install "$1"
    else
        log "$LOG_LEVEL_INFO" "[✓] $1 installed (homebrew)"
    fi
}

setup_basic_tools() {
    echo_blue "Setup basic tools..."

    # git related
    brew_install git
    brew_install gibo
    brew_install ghq
    brew_install gh

    # terminal tools
    brew_install openssl
    brew_install wget
    brew_install rsync
    brew_install fzf
    brew_install jq
    brew_install yq
    brew_install tree
    brew_install direnv
    brew_install shellcheck
    brew_install terraform
    brew_install ansible

    # golang related tools
    brew_install mage
    brew_install golangci-lint

    # language tools
    brew_install anyenv
    brew_install node@22

    # kubernetes tools
    brew_install kubectl
    brew_install kustomize
    brew_install krew
    brew_install k9s

    if [ $# -eq 1 ]; then
        local -n setup_os_specific_func=$1
        $setup_os_specific_func
    fi
}

macos_setup_basic_tools() {
    echo_blue "Setup macos specific tools..."

    brew_install watch
    brew install --cask mas # tool that install app from app store
    brew install --cask appcleaner
    brew install --cask microsoft-edge
    brew install --cask hiddenbar
    brew install --cask karabiner-elements
    brew install --cask licecap
    brew install --cask raycast
    # development tools
    brew install --cask visual-studio-code
    brew install --cask wireshark
}

setup_personal_machine_tools() {
    if [ "$flg_personal_mode" = "false" ]; then
        echo_blue "Skip setup personal machine tools"
        return
    fi
    echo_blue "Setup personal machine tools..."

    brew_install hugo
    brew_install sass/sass/sass

    if [ $# -eq 1 ]; then
        local -n setup_os_specific_func=$1
        $setup_os_specific_func
    fi
}

macos_setup_personal_machine_tools() {
    echo_blue "Setup macos personal machine tools..."

    brew install --cask slack
    brew install --cask zoomus
    mas install 539883307 # LINE
    # development tools
    brew install --cask google-cloud-sdk
    brew install --cask hex-fiend
    brew install --cask balenaetcher
}

setup_zsh() {
    echo_blue "Setup zsh..."

}

startup "$@" # parse arguments givent to this script

case "${os}" in
"macos")
    homebrew_bin_path="/opt/homebrew/bin"
    setup_package_manager
    setup_basic_tools macos_setup_basic_tools
    setup_personal_machine_tools macos_setup_personal_machine_tools
    ;;
"ubuntu")
    homebrew_bin_path="/home/linuxbrew/.linuxbrew/bin"
    setup_package_manager
    setup_basic_tools
    setup_personal_machine_tools
    ;;
esac
