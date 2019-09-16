
export PATH="${HOME}/.zplugin/bin"
zplugin  

export ZPLUG_HOME=/usr/local/opt/zplug
source ${ZPLUG_HOME}/init.zsh

# Make sure to use double quotes
# fuzzy cd command
zplug "b4b4r07/enhancd", use:init.sh
# デフォルトだと .. となっていて、すぐに戻りたいときに辛い。そこで、cd ... と打つと良いようにした
# original : /usr/local/Cellar/zplug/2.4.1/repos/b4b4r07/enhancd/init.sh
export ENHANCD_DOT_ARG=...
export ENHANCD_HOOK_AFTER_CD=ls

# from: では gh-r の他に oh-my-zsh と gist が使える
# oh-my-zsh を指定すると oh-my-zsh のリポジトリにある plugin/ 以下を
# コマンド／プラグインとして管理することができる
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/docker", from:oh-my-zsh
zplug "mollifier/cd-gitroot"
zplug "krujos/cf-zsh-autocompletion"

# zsh-completions
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
# substring search
zplug "zsh-users/zsh-history-substring-search"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# zsh-syntax-highlighting
# compinit 以降に読み込むようにロードの優先度を変更する（2,3にすれば良い）
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# fzf-bin にホスティングされているので注意
# またファイル名が fzf-bin となっているので rename-to:fzf としてリネームする
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf
export FZF_DEFAULT_OPTS='--height 60% --reverse --border'
function select-history() {
  BUFFER=$(\history -n -r 1 | fzf -e --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history
alias cdf='cd $(fzf)'

# ついでに tmux 用の拡張も入れるといい
zplug "junegunn/fzf", as:command, use:bin/fzf-tmux

# 未インストール項目をインストールする
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# プラグインを読み込み、コマンドにパスを通す
# --verbose をつけるとload中のパッケージが表示される
zplug load #--verbose

# load completion init
autoload -U compinit
compinit
