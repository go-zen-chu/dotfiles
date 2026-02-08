# atuin
if hash atuin 2>/dev/null; then
    eval "$(atuin init --disable-up-arrow zsh)"
    export ATUIN_CONFIG_DIR="${HOME}/dotfiles/terminal-tools/atuin"
fi

# starship
if hash starship 2>/dev/null; then
    eval "$(starship init zsh)"
fi
