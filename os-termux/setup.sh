#!/bin/bash

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
    gitleaks
    nodejs-lts # for claude code
    chezmoi    # deploys the dotfiles in home/
)

# termux_install_packages installs (and with "upgrade", upgrades) the termux packages and claude code.
# usage: termux_install_packages <upgrade (true|false)>
termux_install_packages() {
    local upgrade=$1

    if [ "${upgrade}" = "true" ]; then
        log "$LOG_LEVEL_INFO" "upgrade packages with pkg..."
        pkg upgrade -y
    fi
    log "$LOG_LEVEL_INFO" "install packages with pkg..."
    pkg install -y "${termux_packages[@]}"

    if ! hash claude 2>/dev/null; then
        npm install -g @anthropic-ai/claude-code
    elif [ "${upgrade}" = "true" ]; then
        npm update -g @anthropic-ai/claude-code
    fi
}
