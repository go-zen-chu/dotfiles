#!/usr/bin/env bash

UNAME_S=$(uname -s)
if [ "${UNAME_S}" = "Darwin" ] ; then
  # install new zsh
	brew install zsh
	# install zsh plugin manager https://github.com/zplug/zplug
	brew install zplug
	brew install zsh-completions
	# set shell as zsh
	echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
	chsh -s /usr/local/bin/zsh
elif [ -f "/etc/redhat-release" ] ; then
  sudo yum install -y zsh
else
  echo "Not supported OS... Aborting"
  exit 1
fi

cp ./zsh/.zshrc ${HOME}
cp ./zsh/local.zsh ${HOME}
source "${HOME}/.zshrc"
