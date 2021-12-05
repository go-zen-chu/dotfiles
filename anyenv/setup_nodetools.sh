#!/usr/bin/env bash

NODE_VERSION="16.13.1"
nodenv install $NODE_VERSION
nodenv global $NODE_VERSION

# for coc
npm i -g bash-language-server
npm i -g markdownlint
npm i -g textlint
