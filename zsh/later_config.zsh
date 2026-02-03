# Make sure to load after path configuration

if type "direnv" >/dev/null; then
    eval "$(direnv hook zsh)"
fi

if type "anyenv" >/dev/null; then
    # For lazy loading Xenv & languages
    anyenv() {
        unfunction "$0"
        eval "$(anyenv init -)"
        $0 "$@"
    }
    pyenv() {
        # Check if already initialized (prevent VSCode from re-initializing)
        if [[ -n "${PYENV_SHELL}" ]]; then
            command pyenv "$@"
            return
        fi
        unfunction "$0"
        # init anyenv to load xxenv paths
        anyenv -v
        eval "$(pyenv init -)"
        $0 "$@"
    }
    python() {
        unfunction "$0"
        pyenv versions
        $0 "$@"
    }
    goenv() {
        unfunction "$0"
        # init anyenv to load xxenv paths
        anyenv -v
        eval "$(goenv init -)"
        $0 "$@"
    }
    rbenv() {
        unfunction "$0"
        # init anyenv to load xxenv paths
        anyenv -v
        eval "$(rbenv init -)"
        $0 "$@"
    }
fi

if type "wtp" >/dev/null; then
    eval "$(wtp hook zsh)"
fi
