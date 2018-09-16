#!/usr/bin/env bash

git clone https://github.com/riywo/anyenv ${HOME}/.anyenv
# update path for now
PATH=${HOME}/.anyenv/bin:$PATH

anyenv install pyenv
anyenv install goenv
anyenv install rbenv
anyenv install ndenv
