#!/usr/bin/env bash
set -ux

echo "[INFO] Setup vim"

case "${os}" in
"Darwin")
	brew install vim
	;;
"CentOS")
	sudo yum install -y vim
	;;
esac
vim --version

# copy all things inside .vim
if [[ ! -d "$HOME/.vim" ]] ; then
	cp -r ./vim/.vim ${HOME}
	chown -R ${USER} ${HOME}/.vim
fi

# install dein as plugin manager for vim
if [[ ! -d "$HOME/.vim/dein" ]] ; then
	curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh -o ${HOME}/.vim/installer.sh
	sh ${HOME}/.vim/installer.sh ${HOME}/.vim/dein/
fi

cp -i ./vim/.vimrc ${HOME} # place .vimrc which loads settings in dotfiles
