#!/usr/bin/env bash
set -eu

echo "[INFO] Setup anyenv"

if [[ ! -d "${HOME}/.anyenv" ]]; then
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

GO_VERSION="1.15.3"
goenv install $GO_VERSION
goenv global $GO_VERSION

NODE_VERSION="12.20.1"
nodenv install $NODE_VERSION
nodenv install $NODE_VERSION

# for coc
npm i -g bash-language-server
npm i -g markdownlint
npm i -g textlint
