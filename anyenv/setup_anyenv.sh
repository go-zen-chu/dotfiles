#!/usr/bin/env bash

git clone https://github.com/riywo/anyenv ${HOME}/.anyenv
# update path for now
PATH=${HOME}/.anyenv/bin:$PATH

${HOME}/.anyenv/bin/anyenv init

anyenv install pyenv
anyenv install goenv
anyenv install rbenv
anyenv install nodenv
