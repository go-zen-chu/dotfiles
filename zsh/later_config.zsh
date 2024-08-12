# Make sure to load after path configuration

if type "direnv" >/dev/null; then
    source <(direnv hook zsh)
fi

if type "anyenv" >/dev/null; then
    # For lazy loading Xenv & languages
    anyenv() {
        unfunction "$0"
        source <(anyenv init -)
        $0 "$@"
    }
    pyenv() {
        unfunction "$0"
        # init anyenv to load xxenv paths
        anyenv -v
        source <(pyenv init -)
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
        source <(goenv init -)
        $0 "$@"
    }
fi
