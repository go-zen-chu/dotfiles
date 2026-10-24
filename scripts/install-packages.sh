#!/bin/bash
# Installs the packages of this environment: the Brewfile on macOS / Ubuntu and pkg on termux.
# The chezmoi script home/.chezmoiscripts/run_onchange_before_10-install-packages.sh.tmpl runs it
# when the package lists change, and `./install.sh -u` runs it with -u to upgrade every package.
# usage: ./scripts/install-packages.sh [-p (personal mode)] [-u (upgrade)] (run from the repository root)

set -eu

# shellcheck source=scripts/log.sh
source ./scripts/log.sh
# shellcheck source=scripts/env.sh
source ./scripts/env.sh
# shellcheck source=os-linux/setup.sh
source ./os-linux/setup.sh
# shellcheck source=os-termux/setup.sh
source ./os-termux/setup.sh

flg_personal_mode="false"
flg_upgrade="false"
os=$(check_os)
is_ci=$(check_ci)
is_devcontainer=$(check_devcontainer)
brewfile="./Brewfile"

# install_brew_packages installs the packages of the Brewfile and upgrades the outdated ones.
# With "upgrade", it also upgrades the packages that brew bundle does not upgrade (go and krew)
# and offers to uninstall the packages that are not in the Brewfile.
# usage: install_brew_packages <upgrade (true|false)>
install_brew_packages() {
    local upgrade=$1

    # brew drops environment variables without the HOMEBREW_ prefix (see Brewfile)
    export HOMEBREW_DOTFILES_PERSONAL="${flg_personal_mode}"

    if [ "${upgrade}" = "true" ]; then
        brew update
    fi
    brew bundle install --file "${brewfile}"

    if [ "${upgrade}" = "true" ]; then
        local go_package
        while IFS= read -r go_package <&3; do
            go install "${go_package}@latest"
        done 3< <(brew bundle list --go --file "${brewfile}")
        kubectl krew upgrade
        # TIPS: prompts before uninstalling on a TTY, otherwise only lists them and fails
        brew bundle cleanup --file "${brewfile}" || true
    fi
}

# startup parses the options of this script.
startup() {
    local OPTIND opt
    while getopts "pu" opt; do
        case $opt in
        "p") flg_personal_mode="true" ;;
        "u") flg_upgrade="true" ;;
        *)
            echo "Usage: $(basename "$0") [-p (personal mode)] [-u (upgrade)]" 1>&2
            exit 1
            ;;
        esac
    done
    init_log "$LOG_LEVEL_INFO"
}

startup "$@"

echo_blue "Install packages..."
case "${os}" in
"macos")
    install_brew_packages "${flg_upgrade}"
    ;;
"ubuntu")
    install_brew_packages "${flg_upgrade}"
    linux_setup_basic_tools
    if [ "${flg_personal_mode}" = "true" ]; then
        linux_setup_personal_machine_tools
    fi
    ;;
"termux")
    termux_install_packages "${flg_upgrade}"
    ;;
*)
    log "$LOG_LEVEL_ERROR" "Unsupported OS: ${os}"
    exit 1
    ;;
esac
