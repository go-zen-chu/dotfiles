# add path if exists (N-)
path=(/usr/local/bin(N-/) $path)
# for Apple Silicon homebrew
path=(/opt/homebrew/bin(N-/) $path)

# if anyenv exists
path=($HOME/.anyenv/bin(N-/) $path)
if type "anyenv" > /dev/null; then
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
  goenv() {
    unfunction "$0"
    # init anyenv to load xxenv paths
    anyenv -v
    source <(goenv init -)
    $0 "$@"
  }
  rbenv() {
    unfunction "$0"
    # init anyenv to load xxenv paths
    anyenv -v
    source <(rbenv init -)
    $0 "$@"
  }
  nodenv() {
    unfunction "$0"
    # init anyenv to load xxenv paths
    anyenv -v
    source <(nodenv init -)
    $0 "$@"
  }
fi

# if direnv exists
if type "direnv" > /dev/null; then
  # lazy load completion things. https://frederic-hemberger.de/notes/shell/speed-up-initial-zsh-startup-with-lazy-loading/
  direnv() {
    unfunction "$0"
    source <(direnv hook zsh)
    $0 "$@"
  }
fi

# golang
if [ -d "${HOME}/go" ]; then
  GOPATH="${HOME}/go:$GOPATH" # append
  export GOPATH
  path+=(${HOME}/go/bin(N-/)) # append
  # path to goenv inside anyenv
  path=($HOME/.anyenv/envs/goenv/shims(N-/) $path)
fi

# export stored path
export PATH

# set XDG setting
export XDG_CONFIG_HOME="${HOME}/.config"

