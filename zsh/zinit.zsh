export PATH="${HOME}/.zinit/bin:${PATH}"
source ${HOME}/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-bin-gem-node

# alias
zinit snippet 'OMZ::plugins/git/git.plugin.zsh'
zinit snippet 'OMZ::plugins/kubectl/kubectl.plugin.zsh'

# enable completion
autoload -Uz compinit
compinit

# completion
# load before compinit
zinit light "zsh-users/zsh-completions"
zinit ice as"completion"
zinit snippet 'OMZ::plugins/docker/_docker'
zinit ice as"completion"
zinit snippet 'OMZ::plugins/docker-compose/_docker-compose'
if hash kubectl 2>/dev/null ; then
    source <(kubectl completion zsh)
fi

# common
zinit light "mollifier/cd-gitroot"
zinit light 'zsh-users/zsh-autosuggestions'
## kube prompt
zinit light 'jonmosco/kube-ps1'

# setup fzf
zinit ice from"gh-r" as"program"
zinit load junegunn/fzf-bin
export FZF_DEFAULT_OPTS='--height 60% --reverse --border'
function select-history() {
  BUFFER=$(\history -n -r 1 | fzf -e --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history

# should load after compinit. https://github.com/zsh-users/zsh-syntax-highlighting#faq
zinit light "zsh-users/zsh-syntax-highlighting"
# has to load after zsh-syntax-highlighting. https://github.com/zsh-users/zsh-history-substring-search#usage
zinit light "zsh-users/zsh-history-substring-search"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

