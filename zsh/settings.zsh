# 環境変数
export LANG=ja_JP.UTF-8

# 大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完時に色をつける。dir = red, link = purple, exec = cyan
# http://neko-mac.blogspot.com/2015/03/mac_18.html
# LSCOLOR と LS_COLORS は異なるのに注意
zstyle ':completion:*' list-colors di=31 ln=35 ex=36

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=100000
HISTTIMEFORMAT='%Y/%m/%d %H:%M:%S '

# cd したら自動的にpushdする
setopt auto_pushd
# 重複したディレクトリを追加しない
setopt pushd_ignore_dups
# 日本語ファイル名を表示可能にする
setopt print_eight_bit
# beep を無効にする
setopt no_beep
# フローコントロールを無効にする
setopt no_flow_control
# Ctrl+Dでzshを終了しない
setopt ignore_eof
# '#' 以降をコメントとして扱う
setopt interactive_comments
# 複数タブで履歴を共有する設定
setopt share_history
