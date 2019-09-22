#!/usr/bin/env bash

set -eu

echo "[INFO] Setup zsh"

case "${os}" in
"Darwin")
    brew install zsh
    # set shell as zsh
    echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
    ;;
"CentOS")
	  sudo yum install -y zsh
	;;
esac

chsh -s /usr/local/bin/zsh
# install zplugin
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"

cp -i ./zsh/.zshrc "${HOME}"
cp -i ./zsh/local.zsh "${HOME}"
