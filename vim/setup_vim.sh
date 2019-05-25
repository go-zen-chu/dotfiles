#!/usr/bin/env bash
set -ux

UNAME_S=$(uname -s)
if [ "${UNAME_S}" = "Darwin" ] ; then
	brew install vim --with-luajit
elif [ -f "/etc/redhat-release" ] ; then
  sudo yum install -y vim
else
  echo "Not supported OS... Aborting"
  exit 1
fi

# copy all things inside .vim
if [[ ! -d "$HOME/.vim" ]] ; then
	cp ./vim/.vimrc ${HOME} # place .vimrc which loads settings in dotfiles
	cp -r ./vim/.vim ${HOME}
	chown -R ${USER} ${HOME}/.vim
fi

if [[ ! -d "$HOME/.vim/dein" ]] ; then
	# dein setting
	curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh -o ${HOME}/.vim/installer.sh
	sh ${HOME}/.vim/installer.sh ${HOME}/.vim/dein/
fi
