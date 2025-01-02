#!/usr/bin/env bash

set -eu

dotfile_location="${HOME}/dotfiles"
echo "[downloader.sh] Cloning dotfiles to ${dotfile_location}..."

if [ -d "${dotfile_location}" ]; then
    echo "[downloader.sh] ${dotfile_location} already exists. exiting..."
    exit 0
fi

git clone --recurse-submodules https://github.com/go-zen-chu/dotfiles "${dotfile_location}"
cd "${dotfile_location}"
git submodule update --init

echo "[downloader.sh] Dotfiles downloaded to ${dotfile_location}. run ./install.sh for installation"
