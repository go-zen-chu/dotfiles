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
# migrate from https://github.com/junegunn/fzf/blob/fc7630a66d8b07ec90603f7919f8aadf891783ac/shell/key-bindings.zsh#L106
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" fzf) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N   fzf-history-widget
bindkey '^r' fzf-history-widget

# should load after compinit. https://github.com/zsh-users/zsh-syntax-highlighting#faq
zinit light "zsh-users/zsh-syntax-highlighting"

