#!/usr/bin/env bash

UNAME_S=$(uname -s)
if [ "${UNAME_S}" = "Darwin" ] ; then
	brew cask install atom
elif [ "${UNAME_S}" = "Linux" ]; then
  # TODO:
  yum install atom
else
  echo "Not supported OS... Aborting"
  exit 1
fi

if [ ! -e "${HOME}/.atom" ] ; then
  echo "WARNING: atom is not installed properly. Aborting"
else
  cp atom/*.cson "${HOME}/.atom"
  cp atom/*.txt "${HOME}/.atom"
  # install atom package
  apm install --packages-file ${HOME}/.atom/package-list.txt
fi
