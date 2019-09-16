export PATH="${HOME}/.zplugin/bin:${PATH}"
source ${HOME}/.zplugin/bin/zplugin.zsh

zplugin snippet 'OMZ::plugins/git/git.plugin.zsh'
zplugin ice as"completion"
zplugin snippet 'OMZ::plugins/docker/_docker'

zplugin light "zsh-users/zsh-completions"
# substring search
zplugin light "zsh-users/zsh-history-substring-search"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

zplugin light "mollifier/cd-gitroot"
zplugin light "krujos/cf-zsh-autocompletion"

# setup for fzf
export FZF_DEFAULT_OPTS='--height 60% --reverse --border'
function select-history() {
  BUFFER=$(\history -n -r 1 | fzf -e --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history
alias cdf='cd $(fzf)'

autoload -U compinit
compinit

# should load after compinit
zplugin light "zsh-users/zsh-syntax-highlighting"

zplugin ice wait'1' atload'_zsh_autosuggest_start'
zplugin light 'zsh-users/zsh-autosuggestions'
