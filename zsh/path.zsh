# set XDG setting
export XDG_CONFIG_HOME="${HOME}/.config"

# add path if exists (N-)
path=(/usr/local/bin(N-/) $path)
# for Apple Silicon homebrew
path=(/opt/homebrew/sbin(N-/) $path)
path=(/opt/homebrew/bin(N-/) $path)

path=($HOME/.anyenv/bin(N-/) $path)

# golang
if [ -d "${HOME}/go" ]; then
  path+=(${HOME}/go/bin(N-/)) # append
  # path to goenv inside anyenv
  path=($HOME/.anyenv/envs/goenv/shims(N-/) $path)
  path=($(go env GOPATH)/bin(N-/) $path)
fi

# nodejs on ubuntu
if [ -d "/usr/local/lib/nodejs" ]; then
  path+=(/usr/local/lib/nodejs/node-v20.11.1-linux-x64/bin(N-/))
fi

# aqua
if [[ -d "${HOME}/.local/share/aquaproj-aqua" ]]; then
  path=($HOME/.local/share/aquaproj-aqua/bin(N-/) $path)
  export AQUA_GLOBAL_CONFIG=${HOME}/dotfiles/aqua/aqua.yaml
fi

# kubectl krew
path=($HOME/.krew/bin(N-/) $path)

# python poetry
path=($HOME/.local/bin(N-/) $path)

# export stored path at last
export PATH

