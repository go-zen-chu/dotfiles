UNAME=`uname`
if [[ $UNAME == 'Darwin' ]] ; then
  # mac だと fn + delete が ~ になるので、修正
  bindkey "^[[3~" delete-char
  # option + 矢印
  bindkey "^[^[[D" backward-word
  bindkey "^[^[[C" forward-word
fi
# zplug でインストールしたプラグインが keybind を書き換えてしまうことがある
# https://superuser.com/questions/523564/emacs-keybindings-in-zsh-not-working-ctrl-a-ctrl-e
bindkey -e
