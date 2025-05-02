# set XDG setting
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"

# TIPS: add path if exists (N-). path+= will append at the end of PATH
# homebrew
path=(/opt/homebrew/bin(N-/) $path) # for Apple Silicon
path=(/home/linuxbrew/.linuxbrew/bin(N-/) $path) # for linux

# ubuntu snap
path=(/snap/bin(N-/) $path)

# anyenv
path=("${HOME}/.anyenv/bin"(N-/) $path)

# golang
if [ -d "${HOME}/go" ]; then
  path=(${HOME}/go/bin(N-/) $path) # append
  # path to goenv inside anyenv
  path=($HOME/.anyenv/envs/goenv/shims(N-/) $path)
  path=($(go env GOPATH)/bin(N-/) $path)
fi

# nodejs installed by homebrew
nodejs_install_path=$(brew --prefix node@22)
if [ -d "${nodejs_install_path}" ]; then
  path=(${nodejs_install_path}/bin(N-/) $path)
fi
if hash pnpm 2>/dev/null; then
  export PNPM_HOME="${HOME}/.local/share/pnpm"
  path=($PNPM_HOME $path)
fi

# kubectl krew
path=($HOME/.krew/bin(N-/) $path)

# python poetry
path=($HOME/.local/bin(N-/) $path)

# export stored path at last
export PATH

