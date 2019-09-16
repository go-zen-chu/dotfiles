#!/usr/bin/env bash
set -ux

echo "[INFO] Setup vim"

case "${os}" in
"Darwin")
	brew install vim --with-luajit
	;;
"CentOS")
	sudo yum install -y vim
	;;
esac
vim --version

if [[ ! -d "$HOME/.vim/dein" ]] ; then
	# dein setting
	curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh -o ${HOME}/.vim/installer.sh
	sh ${HOME}/.vim/installer.sh ${HOME}/.vim/dein/
fi

# copy all things inside .vim
if [[ ! -d "$HOME/.vim" ]] ; then
	cp ./vim/.vimrc ${HOME} # place .vimrc which loads settings in dotfiles
	cp -r ./vim/.vim ${HOME}
	chown -R ${USER} ${HOME}/.vim
fi