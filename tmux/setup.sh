#!/usr/bin/env bash
set -ux

source ./make/util.sh

echo_green "[INFO] setup tmux"
os=$(check_os)
# check command exists
if ! hash tmux 2>/dev/null; then
	case "${os}" in
	"MacOS")
		brew install tmux
		brew install reattach-to-user-namespace
		;;
	"CentOS")
		declare TMUX_VERSION="2.8"
		pushd "${PWD}" || exit
		yum install -y gcc make libevent-devel ncurses-devel
		cd /usr/local/src || exit
		curl -o tmux-${TMUX_VERSION}.tar.gz -L https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
		tar -xvf tmux-${TMUX_VERSION}.tar.gz
		cd tmux-${TMUX_VERSION} || exit
		./configure && make
		make install >/dev/null
		popd || exit
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
	# backup
	cp "${HOME}/.tmux.conf" "${HOME}/.tmux.conf.$(date '+%Y%m%d-%H%M%S').bk"
fi
cp -f ./tmux/.tmux.conf "${HOME}"

echo_green "[IMPORTANT] Make sure to run ctrl+b ctrl+I for installing tmux plugins"
echo_green "[INFO] Finish setup tmux"
