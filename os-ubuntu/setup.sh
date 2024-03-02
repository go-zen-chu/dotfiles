#!/usr/bin/env bash
set -u

source ./make/util.sh
echo_green "[INFO] Setup ubuntu"

# setup locale when your env is initialized
sudo dpkg-reconfigure locales

# apt manage system-wide packages
sudo apt update
# to enable cgo in golang, gcc is required
sudo apt install -y gcc
# development tools
sudo apt install -y \
    protobuf-compiler \
    ansible
sudo apt autoremove && sudo apt clean

# install nodejs
VERSION=v20.11.1
wget "https://nodejs.org/dist/${VERSION}/node-${VERSION}-linux-x64.tar.xz" -O nodejs.tar.xz
sudo tar -xJvf nodejs.tar.xz -C /usr/local/lib/nodejs
rm nodejs.tar.xz
