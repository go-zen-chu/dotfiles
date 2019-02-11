#!/usr/bin/env bash
set -ux

xcode-select -p
# if installed returns 0 else install
if [[ $? != 0 ]] ; then
  xcode-select --install
else
  echo "developer tool is already installed"
fi
