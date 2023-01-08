#!/usr/bin/env bash
set -u

curl -sSfL https://raw.githubusercontent.com/aquaproj/aqua-installer/v2.0.2/aqua-installer | bash
# temporary add to PATH (add to PATH in zshrc for permanent configuration)
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua"
cp ./aqua/aqua.yaml ${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml
# set to global config
export AQUA_GLOBAL_CONFIG=${AQUA_GLOBAL_CONFIG:-}:${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml
aqua i -a
gh config set editor vim
