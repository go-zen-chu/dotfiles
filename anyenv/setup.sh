#!/usr/bin/env bash
set -eu

echo "[INFO] Setup anyenv"

git clone https://github.com/riywo/anyenv "${HOME}/.anyenv"
# update path for now
export PATH=${HOME}/.anyenv/bin:$PATH

anyenv init
anyenv install --force-init 

anyenv install pyenv
anyenv install goenv
anyenv install rbenv
anyenv install nodenv
