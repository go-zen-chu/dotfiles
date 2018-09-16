#!/usr/bin/env bash

UNAME_S=$(uname -s)
if [ "${UNAME_S}" = "Darwin" ] ; then
  brew install bash-completion
elif [ "${UNAME_S}" = "Linux" ]; then
  yum install bash-completion
else
  echo "Not supported OS... Aborting"
  exit 1
fi

cp bash/.bash_profile ${HOME}
cp bash/.inputrc ${HOME}
cp bash/.bashrc ${HOME}
source "${HOME}/.bash_profile"
