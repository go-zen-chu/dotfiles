#!/usr/bin/env bash
set -u

source ./make/util.sh
echo_green "[INFO] Setup git"

# ignore generated files 
git config --global core.excludesfile "${HOME}/dotfiles/git/global-ignore"
git config --global push.default current
git config --global pull.rebase false  

os=$(check_os)
# check command exists
if ! hash tig 2>/dev/null ; then
	case "${os}" in
	"MacOS")
		brew install tig
		;;
	"CentOS")
		echo_red "TBD"
		;;
	"ArchLinux")
		sudo pacman -Sy --noconfirm tig
		;;
	esac
fi
if [[ ! -f "${HOME}/.tigrc" ]] ; then
	cp ./git/.tigrc "${HOME}"
fi
echo_green "[INFO] Finish setup git"
