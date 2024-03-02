#!/usr/bin/env bash
set -eu

echo "[INFO] Setup nodejs tools"
# node version manager
npm install -g n
npm install -g yarn
npm install -g typescript
# used in nvim
npm install -g bash-language-server
