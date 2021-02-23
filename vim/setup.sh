#!/usr/bin/env bash
set -u

source ./make/util.sh

echo_green "[INFO] setup vim"
os=$(check_os)
# check command exists
if ! hash vim 2>/dev/null; then
	case "${os}" in
	"MacOS")
		brew install vim
		;;
	"CentOS")
		sudo yum install -y vim
		;;
	"ArchLinux")
		sudo pacman -Sy --noconfirm vim
		;;
	esac
fi

# show vim info
vim --version

# copy all things inside .vim
if [[ ! -d "${HOME}/.vim" ]]; then
	cp -r ./vim/.vim "${HOME}"
	chown -R "${USER}" "${HOME}/.vim"
fi

# install vim-plug
if [[ ! -f "${HOME}/.vim/autoload/plug.vim" ]]; then
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
# setup .vimrc
if [[ -f "${HOME}/.vimrc" ]]; then
	if diff "${HOME}/.vimrc" ./vim/.vimrc >/dev/null; then 
		echo_green ".vimrc is same as dotfiles"
	else
		# backup
		cp "${HOME}/.vimrc" "${HOME}/.vimrc.$(date '+%Y%m%d-%H%M%S').bk"
	fi
fi
cp -f ./vim/.vimrc "${HOME}"

# run vim command and install plugin
vim -c ':PlugInstall' -c 'qa!'

echo_green "[INFO] Finish setup vim"
