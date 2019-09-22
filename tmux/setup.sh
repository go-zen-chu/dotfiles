#!/usr/bin/env bash
set -ux

echo "[INFO] Setup tmux"

case "${os}" in
"Darwin")
	brew install tmux
	brew install reattach-to-user-namespace
	;;
"CentOS")
	declare TMUX_VERSION="2.8"
	pushd "${PWD}"
	yum install -y gcc make libevent-devel ncurses-devel
	cd /usr/local/src
	curl -o tmux-${TMUX_VERSION}.tar.gz -L https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
	tar -xvf tmux-${TMUX_VERSION}.tar.gz
	cd tmux-${TMUX_VERSION}
	./configure && make
	make install > /dev/null
	popd
	;;
esac
tmux -V

# install tpm
if [[ ! -d  "${HOME}/.tmux" ]] ; then
	git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
fi

# set tmux config
cp -i ./tmux/.tmux.conf "${HOME}"