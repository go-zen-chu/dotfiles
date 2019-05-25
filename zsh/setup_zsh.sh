#!/usr/bin/env bash

set -eux

UNAME_S=$(uname -s)

if [ "${UNAME_S}" = "Darwin" ] ; then
  # install new zsh
  brew install zsh
  # install zsh plugin manager https://github.com/zplug/zplug
  brew install zplug
  brew install zsh-completions
  # set shell as zsh
  echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
elif [ -f "/etc/redhat-release" ] ; then
  sudo yum install -y zsh
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
else
  echo "Not supported OS... Aborting"
  exit 1
fi
chsh -s /usr/local/bin/zsh

if [ ! -f ${HOME}/.zshcr ] ; then
  cp ./zsh/.zshrc ${HOME}
  cp ./zsh/local.zsh ${HOME}
fi

