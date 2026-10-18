#!/bin/bash

# shellcheck disable=SC2154 # log functions and variables are set by install.sh, which sources this file
set -eu

# Homebrew does not support termux (Android), so termux has its own small setup with pkg.
# Only tools used on termux are installed here.
termux_packages=(
    # terminal tools
    zsh
    vim
    starship
    fzf
    atuin
    jq
    tree
    ncurses-utils # tput
    # development tools
    git
    gh
    openssh
    nodejs-lts # for claude code
)

termux_setup() {
    echo_blue "Setup termux..."

    log "$LOG_LEVEL_INFO" "install packages with pkg..."
    pkg install -y "${termux_packages[@]}"

    echo_blue "Setup git..."
    configure_git
    # gitleaks is not provided by termux, so the global pre-commit hook is not set up

    echo_blue "Setup claude code..."
    if hash claude 2>/dev/null; then
        log "$LOG_LEVEL_INFO" "[✓] claude-code installed"
    else
        npm install -g @anthropic-ai/claude-code
    fi

    echo_blue "Setup zsh..."
    # termux has no /etc/shells and sudo, its chsh changes the shell of termux sessions
    if [ "$(basename "${SHELL-}")" != "zsh" ]; then
        chsh -s zsh
    fi
    deploy_zsh_config

    echo_blue "Setup vim..."
    deploy_vim_config
}
