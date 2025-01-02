#!/usr/bin/env bash

set -eux

dotfile_location="${HOME}/dotfiles-test"
git clone --recurse-submodules https://github.com/go-zen-chu/dotfiles "${dotfile_location}"
cd "${dotfile_location}"
git submodule update --init

echo "[downloader.sh] Dotfiles downloaded to ${dotfile_location}. run ./install.sh for installation"
