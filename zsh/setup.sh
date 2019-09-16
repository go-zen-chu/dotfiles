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

if confirm_overwrite "${HOME}/.zshrc" ; then
    cp ./zsh/.zshrc ${HOME}
fi
if confirm_overwrite "${HOME}/local.zsh" ; then
    cp ./zsh/local.zsh ${HOME}
fi