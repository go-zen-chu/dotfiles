UNAME=$(uname)
if [[ $UNAME == 'Darwin' ]]; then
	# in mac, fn + delete gets ~
	bindkey "^[[3~" delete-char
	# option + right/left
	bindkey "^[^[[D" backward-word
	bindkey "^[^[[C" forward-word
fi
if [[ $UNAME == 'Linux' ]]; then
	# in linux, alt + right/left
	bindkey "^[[1;5C" forward-word
	bindkey "^[[1;5D" backward-word
fi
bindkey -e
