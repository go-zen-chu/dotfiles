#!/usr/bin/env bash

UNAME_S=$(uname -s)
if [ "${UNAME_S}" = "Darwin" ] ; then
	brew install vim
elif [ "${UNAME_S}" = "Linux" ]; then
  #TODO:
  yum install vim
else
  echo "Not supported OS... Aborting"
  exit 1
fi

# copy all things inside .vim
cp ./vim/.vimrc ${HOME}
cp -r ./vim/.vim ${HOME}
chown -R ${USER} ${HOME}/.vim
# dein setting
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh -o ${HOME}/.vim/installer.sh
sh ${HOME}/.vim/installer.sh ${HOME}/.vim/dein/
