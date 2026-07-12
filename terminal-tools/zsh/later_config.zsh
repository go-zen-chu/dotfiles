# Make sure to load after path configuration

if type "direnv" >/dev/null; then
    eval "$(direnv hook zsh)"
fi

if type "wtp" >/dev/null; then
    eval "$(wtp hook zsh)"
fi
