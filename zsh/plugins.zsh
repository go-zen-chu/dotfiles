# enable completion
autoload -Uz compinit
compinit

# alias
source plugins/ohmyzsh/plugins/git/git.plugin.zsh
source plugins/ohmyzsh/plugins/kubectl/kubectl.plugin.zsh

# completions
## https://github.com/zsh-users/zsh-completions#manual-installation
fpath=(plugins/zsh-completions/src $fpath)

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
source plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# prompt
source plugins/kube-ps1/kube-ps1.sh

# should load after compinit. https://github.com/zsh-users/zsh-syntax-highlighting#faq
source plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
