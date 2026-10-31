#!/bin/bash
# Bootstraps the environment: installs Homebrew (pkg on termux) and chezmoi, then applies the dotfiles
# in home/ with chezmoi. The chezmoi scripts in home/.chezmoiscripts install the packages of the Brewfile
# and configure the tools.

set -eu

# shellcheck source=scripts/log.sh
source ./scripts/log.sh
# shellcheck source=scripts/env.sh
source ./scripts/env.sh
# shellcheck source=os-macos/setup.sh
source ./os-macos/setup.sh

flg_verbose="false"
flg_personal_mode="false"
flg_upgrade="false"
arg_git_email=""

log_level=$LOG_LEVEL_INFO
os=""
repo_dir="$(pwd)"
is_ci="false"
is_devcontainer="false"

### setup methods

# startup parses the options and checks the environment.
startup() {
    log "$LOG_LEVEL_INFO" "Start dotfile install script"
    cmdname=$(basename "$0")

    local OPTIND
    while getopts "vpue:" opt; do
        case $opt in
        "e") arg_git_email="$OPTARG" ;;
        "v") flg_verbose="true" ;;
        "p") flg_personal_mode="true" ;;
        "u") flg_upgrade="true" ;;
        *)
            echo "Usage: $cmdname [-e (git email)] [-v (verbose)] [-p (personal mode)] [-u (upgrade every package)]" 1>&2
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

    # devcontainer image is built without a user, so git email is set at container creation
    if [ -z "$arg_git_email" ] && [ "${is_devcontainer}" = "false" ]; then
        log "$LOG_LEVEL_ERROR" "-e option (git email) is required"
    fi

    if [[ "${os}" == unsupported* ]]; then
        log "$LOG_LEVEL_ERROR" "Unsupported OS: ${os}"
        exit 1
    fi
}

# check_env prints the environment this script runs in.
check_env() {
    echo_blue "Checking environment..."

    os=$(check_os)
    is_ci=$(check_ci)
    is_devcontainer=$(check_devcontainer)
    echo "OS            : ${os}"
    echo "CPU           : $(check_cpu_arch)"
    echo "Bash Version  : ${BASH_VERSION}"
    echo "User          : $(check_current_user)"
    echo "HOME          : ${HOME}"
    echo "Repository    : ${repo_dir}"
    echo "Is CI         : ${is_ci}"
    echo "Personal mode : ${flg_personal_mode}"
    echo "Upgrade       : ${flg_upgrade}"
    echo "Devcontainer  : ${is_devcontainer}"
    echo "Log level     : $(get_log_level "$log_level")"
}

# setup_homebrew installs Homebrew and chezmoi, and adds Homebrew to PATH.
# usage: setup_homebrew <bin directory of Homebrew>
setup_homebrew() {
    local homebrew_bin_path=$1
    echo_blue "Setup Homebrew..."

    if ! hash brew 2>/dev/null && [ ! -x "${homebrew_bin_path}/brew" ]; then
        log "$LOG_LEVEL_INFO" "[ ] Homebrew not installed. Installing..."
        if [ "$is_ci" = "true" ]; then
            export NONINTERACTIVE=1
        fi
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        unset NONINTERACTIVE
    fi
    export PATH="${homebrew_bin_path}:${PATH}"
    log "$LOG_LEVEL_INFO" "[✓] Homebrew installed"

    if ! hash chezmoi 2>/dev/null; then
        brew install chezmoi
    fi
}

# setup_termux installs chezmoi with pkg because Homebrew does not support termux (Android).
setup_termux() {
    echo_blue "Setup termux..."
    if ! hash chezmoi 2>/dev/null; then
        pkg install -y chezmoi
    fi
}

# backup_changed_targets moves the files that chezmoi is going to overwrite to <path>.<date>.bk,
# so that local changes (e.g. made before this repository was managed by chezmoi) are kept.
backup_changed_targets() {
    local status target
    while IFS= read -r status <&3; do
        # chezmoi status: 1st column = since chezmoi last wrote it, 2nd column = what apply will do
        case "${status:1:1}" in
        "M" | "D") ;;
        *) continue ;;
        esac
        target="${status:3}"
        if [ -e "${target}" ] || [ -L "${target}" ]; then
            log "$LOG_LEVEL_WARN" "backup ${target} to ${target}.$(date '+%Y%m%d-%H%M%S').bk"
            mv "${target}" "${target}.$(date '+%Y%m%d-%H%M%S').bk"
        fi
    done 3< <(chezmoi status --path-style absolute --exclude scripts)
}

# apply_dotfiles generates the chezmoi config from the options and applies home/ to $HOME.
apply_dotfiles() {
    echo_blue "Apply dotfiles with chezmoi..."

    chezmoi init --source "${repo_dir}" \
        --promptString "email=${arg_git_email}" \
        --promptBool "personal=${flg_personal_mode}"
    backup_changed_targets
    chezmoi apply --force
}

# upgrade_packages upgrades every package, including the ones whose list did not change.
upgrade_packages() {
    echo_blue "Upgrade packages..."

    local install_options=("-u")
    if [ "${flg_personal_mode}" = "true" ]; then
        install_options+=("-p")
    fi
    ./scripts/install-packages.sh "${install_options[@]}"
}

### install

startup "$@" # parse arguments given to this script

case "${os}" in
"macos")
    macos_check_developer_tool
    setup_homebrew "/opt/homebrew/bin"
    ;;
"ubuntu")
    setup_homebrew "/home/linuxbrew/.linuxbrew/bin"
    ;;
"termux")
    setup_termux
    ;;
esac

if [ "${flg_upgrade}" = "true" ] && git rev-parse --git-dir >/dev/null 2>&1; then
    git pull --ff-only || log "$LOG_LEVEL_WARN" "failed to pull ${repo_dir}, apply the current checkout"
fi
apply_dotfiles
if [ "${flg_upgrade}" = "true" ]; then
    upgrade_packages
fi

echo_green "setup finished successfully!"
log "$LOG_LEVEL_INFO" "done"
