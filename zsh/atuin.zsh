if hash atuin 2>/dev/null; then
    eval "$(atuin init --disable-up-arrow zsh)"
    export ATUIN_CONFIG_DIR="${HOME}/dotfiles/atuin"
fi
