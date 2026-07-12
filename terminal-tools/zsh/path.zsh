# set XDG setting
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"

# TIPS: add path if exists (N-). path+= will append at the end of PATH
# homebrew
path=(/opt/homebrew/bin(N-/) $path) # for Apple Silicon
path=(/home/linuxbrew/.linuxbrew/bin(N-/) $path) # for linux

# ubuntu snap
path=(/snap/bin(N-/) $path)

# golang (installed via Homebrew; toolchain managed by Go itself)
export GOTOOLCHAIN=auto
if hash go 2>/dev/null; then
  path=($(go env GOPATH)/bin(N-/) $path)
fi

# nodejs installed by homebrew
nodejs_install_path=$(brew --prefix node@24)
if [ -d "${nodejs_install_path}" ]; then
  path=(${nodejs_install_path}/bin(N-/) $path)
fi
if hash pnpm 2>/dev/null; then
  export PNPM_HOME="${HOME}/.local/share/pnpm"
  path=($PNPM_HOME ${PNPM_HOME}/bin(N-/) $path)
fi

# kubectl krew
path=($HOME/.krew/bin(N-/) $path)

# user-local bins (uv-installed tools, pipx, etc.)
path=($HOME/.local/bin(N-/) $path)

# export stored path at last
export PATH

