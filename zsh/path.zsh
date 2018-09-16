# pathの追加（N-は存在しなかったら追加しないという意味）
# 空白で他のパスを追加できる
path=(/usr/local/bin(N-/) $path)
# zsh-completions setting
fpath=(/usr/local/share/zsh-completions $fpath)

# anyenv exists
path+=($HOME/.anyenv/bin(N-/)) # append
if type "anyenv" > /dev/null; then
  eval "$(anyenv init -)"
fi

# direnv exists
if type "direnv" > /dev/null; then
  eval "$(direnv hook zsh)"
fi

# golang
path+=($HOME/go/bin(N-/)) # append
if [ -d "$HOME/go" ]; then
  GOPATH="$HOME/go:$GOPATH" # append
  export GOPATH
  path+=($HOME/go/bin(N-/)) # append
fi

# export stored path
export PATH
