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

# show vim info
vim --version

# copy all things inside .vim
if [[ ! -d "$HOME/.vim" ]] ; then
	cp -r ./vim/.vim ${HOME}
	chown -R ${USER} ${HOME}/.vim
fi

# install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	 https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

cp -i ./vim/.vimrc ${HOME} # place .vimrc which loads settings in dotfiles

