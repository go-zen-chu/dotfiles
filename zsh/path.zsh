# set XDG setting
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"

# add path if exists (N-)
# homebrew
path+=(/opt/homebrew/bin(N-/)) # for Apple Silicon
path+=("/home/linuxbrew/.linuxbrew/bin"(N-/)) # for linux

# anyenv
path+=("${HOME}/.anyenv/bin"(N-/))
# golang
if [ -d "${HOME}/go" ]; then
  path+=(${HOME}/go/bin(N-/)) # append
  # path to goenv inside anyenv
  path+=($HOME/.anyenv/envs/goenv/shims(N-/))
  path+=($(go env GOPATH)/bin(N-/))
fi

# nodejs installed by homebrew
nodejs_install_path=$(brew --prefix node@22)
if [ -d "${nodejs_install_path}" ]; then
  path+=(${nodejs_install_path}/bin(N-/))
fi
if hash pnpm 2>/dev/null; then
  export PNPM_HOME="${HOME}/.local/share/pnpm"
  path+=($PNPM_HOME)
fi

# kubectl krew
path+=($HOME/.krew/bin(N-/))

# python poetry
path+=($HOME/.local/bin(N-/))

# export stored path at last
export PATH

