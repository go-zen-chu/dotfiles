# OS independent setting
UNAME=`uname`
if [[ $UNAME == 'Darwin' ]] ; then
  # tmux の色設定を変えて、vimのcolorschemaを適用できるようにする
  alias tmux="tmux -2"
  export LSCOLORS=bxfxcxdxgxegedabagacad
  alias ls='ls -a -G -F'
elif [[ $UNAME == 'Linux' ]] ; then
  # バグるのでコメントアウト
  #alias -g tmux="TERM=xterm-256color tmux"
  alias ls='ls -a --color=auto -F'
fi

# グローバルエイリアス(すべての場所でひっかかってしまうので注意)
# cat hoge.txt G huga というように使える(通常の alias は先頭だけマッチ)
alias -g L='| less -iMRS'
alias -g G='| grep --color=auto'
alias -g P='| pbcopy'
alias -g X='| xargs'

# relogin current shell
alias relogin='exec $SHELL -l'
# history を全件かつlessで表示
alias history='history -E 1 | less'
alias ll='ls -l'
alias less='less -iMRS'
alias rmdir='rm -rf'
alias cpdir='cp -R'
alias gitlog='git log --graph --color --oneline'

if [ -d "$HOME/dotfiles/plantuml" ] ; then
    alias plantuml='plantuml -config "$HOME/dotfiles/plantuml/plantuml_cf_theme/config.txt"'
fi
