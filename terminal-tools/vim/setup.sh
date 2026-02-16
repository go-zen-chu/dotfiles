#!/usr/bin/env bash
set -eu

source ./scripts/log.sh

echo_green "[INFO] setup vim"
os=$(check_os)
# check command exists
if ! hash vim 2>/dev/null; then
	case "${os}" in
	"MacOS")
		brew install vim
		;;
	"ArchLinux")
		sudo pacman -Sy --noconfirm vim
		;;
	"Ubuntu")
		sudo apt-get install -y vim
		;;
	esac
fi

# show vim info
vim --version

# copy all things inside .vim
if [[ ! -d "${HOME}/.vim" ]]; then
	cp -r ./terminal-tools/vim/.vim "${HOME}"
	chown -R "${USER}" "${HOME}/.vim"
fi

# setup .vimrc
if [[ -f "${HOME}/.vimrc" ]]; then
	if diff "${HOME}/.vimrc" ./terminal-tools/vim/.vimrc >/dev/null; then
		echo_green ".vimrc is same as dotfiles"
	else
		# backup
		cp "${HOME}/.vimrc" "${HOME}/.vimrc.$(date '+%Y%m%d-%H%M%S').bk"
	fi
fi
cp -f ./terminal-tools/vim/.vimrc "${HOME}"

# in CI environment, command below does not work (requires UI)
set +u
if [[ -z $CI ]]; then
	echo_green "[INFO] Setting up vim-plug in non-CI environment (CI=$CI)"
	# install vim-plug
	if [[ ! -f "${HOME}/.vim/autoload/plug.vim" ]]; then
		curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	fi
	# run vim command and install plugin
	vim -c ':PlugInstall' -c 'qa!'
fi
set -u

echo_green "[INFO] Finish setup vim"
