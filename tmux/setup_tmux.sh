#!/usr/bin/env bash
set -ux

UNAME_S=$(uname -s)
if [ "${UNAME_S}" = "Darwin" ] ; then
	brew install tmux
elif [ -f "/etc/redhat-release" ] ; then
  sudo yum -y install gcc libevent-devel ncurses-devel
	TMUX_VER="2.8"
	TMUX_STR="tmux-${TMUX_VER}"
	wget https://github.com/tmux/tmux/releases/download/${TMUX_VER}/${TMUX_STR}.tar.gz
	tar xvf ${TMUX_STR}.tar.gz
	cd ${TMUX_STR}
	./configure
	make
	make install
	cd ..
	rm ${TMUX_STR}.tar.gz
	rm -rf ${TMUX_STR}
else
  echo "Not supported OS... Aborting"
  exit 1
fi

if [[ ! -d  "${HOME}/.tmux" ]] ; then
	git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
	cp ./tmux/.tmux.conf ${HOME}
fi
