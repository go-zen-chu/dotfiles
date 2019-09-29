#!/usr/bin/env bash

set -eu

echo "[INFO] Setup git"

# ignore generated files 
git config --global core.excludesfile "${HOME}/dotfiles/git/global-ignore"

