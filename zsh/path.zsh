# add path if exists (N-)
path=(/usr/local/bin(N-/) $path)

# if anyenv exists
path=($HOME/.anyenv/bin(N-/) $path)
if type "anyenv" > /dev/null; then
  eval "$(anyenv init -)"
fi
# if direnv exists
if type "direnv" > /dev/null; then
  eval "$(direnv hook zsh)"
fi

# golang
if [ -d "${HOME}/go" ]; then
  GOPATH="${HOME}/go:$GOPATH" # append
  export GOPATH
  path+=(${HOME}/go/bin(N-/)) # append
fi

# export stored path
export PATH

# set XDG setting
export XDG_CONFIG_HOME="${HOME}/.config"

