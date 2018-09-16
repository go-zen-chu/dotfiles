#!/usr/bin/env bash

UNAME_S=$(uname -s)
if [ "${UNAME_S}" = "Darwin" ] ; then
  # install plantuml
  brew cask install java
  brew install plantuml
elif [ "${UNAME_S}" = "Linux" ]; then
  #TODO:
  echo "not supported for linux yet..."
  exit 1
else
  echo "Not supported OS... Aborting"
  exit 1
fi
