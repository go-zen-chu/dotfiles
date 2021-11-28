# enable completion
autoload -Uz compinit
compinit

DOTFILES_INSTALLED_PATH="$HOME"
DOTFILES_PATH="${DOTFILES_INSTALLED_PATH}/dotfiles"
DOTFILES_ZSH_PLUGINS_PATH="${DOTFILES_PATH}/zsh/plugins"
DOTFILES_ZSH_CACHE_PATH="${DOTFILES_PATH}/zsh/cache"

# used in oh-my-zsh
ZSH_CACHE_DIR="${DOTFILES_ZSH_CACHE_PATH}"

# update installed plugins
alias df-zsh-plugin-update='dotfiles_zsh_plugin_update'
dotfiles_zsh_plugin_update(){
  pushd "${DOTFILES_PATH}/zsh"
  echo "[dotfiles/zsh] Update plugins..."
  git submodule update --init --recursive
  popd
}

# alias
source ${DOTFILES_ZSH_PLUGINS_PATH}/ohmyzsh/plugins/git/git.plugin.zsh
source ${DOTFILES_ZSH_PLUGINS_PATH}/ohmyzsh/plugins/kubectl/kubectl.plugin.zsh

# completions
## https://github.com/zsh-users/zsh-completions#manual-installation
fpath=(${DOTFILES_ZSH_PLUGINS_PATH}/zsh-completions/src $fpath)

## lazy load completion things. https://frederic-hemberger.de/notes/shell/speed-up-initial-zsh-startup-with-lazy-loading/
## Check if 'kubectl' is a command in $PATH
if [ $commands[kubectl] ]; then
  # Placeholder 'kubectl' shell function:
  # Will only be executed on the first call to 'kubectl'
  kubectl() {
    # Remove this function, subsequent calls will execute 'kubectl' directly
    unfunction "$0"
    source <(kubectl completion zsh)
    # Execute 'kubectl' binary
    $0 "$@"
  }
fi

# inputs
source ${DOTFILES_ZSH_PLUGINS_PATH}/zsh-autosuggestions/zsh-autosuggestions.zsh

# prompt
source ${DOTFILES_ZSH_PLUGINS_PATH}/kube-ps1/kube-ps1.sh

# should load after compinit. https://github.com/zsh-users/zsh-syntax-highlighting#faq
source ${DOTFILES_ZSH_PLUGINS_PATH}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
