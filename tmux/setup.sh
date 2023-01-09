#!/usr/bin/env bash
set -u

source ./make/util.sh
echo_green "[INFO] setup tmux"
os=$(check_os)
# check command exists
if ! hash tmux 2>/dev/null; then
	case "${os}" in
	"MacOS")
		brew install tmux
		;;
	"ArchLinux")
		# will install tmux >= 3.0
		sudo pacman -Sy --noconfirm tmux
		;;
	esac
fi

tmux -V

# install tpm
if [[ ! -d "${HOME}/.tmux/plugins/tpm" ]]; then
	git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
fi

# set tmux config
if [[ -f "${HOME}/.tmux.conf" ]]; then
	if diff "${HOME}/.tmux.conf" ./tmux/.tmux.conf >/dev/null; then
		echo_green ".tmux.conf is same as dotfiles"
	else
		# backup
		cp "${HOME}/.tmux.conf" "${HOME}/.tmux.conf.$(date '+%Y%m%d-%H%M%S').bk"
	fi
fi
cp -f ./tmux/.tmux.conf "${HOME}"

echo_green "[IMPORTANT] Make sure to run ctrl+b ctrl+I for installing tmux plugins"
echo_green "[INFO] Finish setup tmux"
