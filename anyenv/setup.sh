#!/usr/bin/env bash
set -eu

echo "[INFO] Setup anyenv"

if [[ ! -d "${HOME}/.anyenv" ]] ; then
    git clone https://github.com/riywo/anyenv "${HOME}/.anyenv"
fi
# update path for now
export PATH=${HOME}/.anyenv/bin:$PATH

anyenv init || true # for skipping CI
anyenv install --force-init 

anyenv install pyenv
anyenv install goenv
anyenv install rbenv
anyenv install nodenv
