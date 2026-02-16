#===== fzf =====
if hash fzf 2>/dev/null; then
    # migrate from https://github.com/junegunn/fzf/blob/fc7630a66d8b07ec90603f7919f8aadf891783ac/shell/key-bindings.zsh#L106
    export FZF_DEFAULT_OPTS='--height 60% --reverse --border'

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
    # register new widget
    zle     -N   fzf-history-widget
    bindkey '^r' fzf-history-widget
fi

#===== atuin =====
if hash atuin 2>/dev/null; then
    eval "$(atuin init --disable-up-arrow zsh)"
    export ATUIN_CONFIG_DIR="${HOME}/dotfiles/terminal-tools/atuin"
fi

#===== starship =====
if hash starship 2>/dev/null; then
    eval "$(starship init zsh)"
fi
