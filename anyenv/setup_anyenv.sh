#!/usr/bin/env bash

set -eux

git clone https://github.com/riywo/anyenv ${HOME}/.anyenv
# update path for now
PATH=${HOME}/.anyenv/bin:$PATH >> ${HOME}/local.zsh

anyenv init
anyenv install --force-init 

anyenv install pyenv
anyenv install goenv
anyenv install rbenv
anyenv install nodenv
