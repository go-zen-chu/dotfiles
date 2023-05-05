#!/usr/bin/env bash
set -u

source ./make/util.sh
echo_green "[INFO] Setup ubuntu"

# setup locale when your env is initialized
sudo dpkg-reconfigure locales

sudo apt-get update
# to enable cgo in golang, gcc is required
sudo apt-get install gcc
# development tools
sudo apt install -y protobuf-compiler
sudo apt-get clean
