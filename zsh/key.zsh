UNAME=`uname`
if [[ $UNAME == 'Darwin' ]] ; then
  # in mac, fn + delete gets ~
  bindkey "^[[3~" delete-char
  # option + right/left
  bindkey "^[^[[D" backward-word
  bindkey "^[^[[C" forward-word
fi
bindkey -e
