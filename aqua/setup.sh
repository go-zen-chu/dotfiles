#!/usr/bin/env bash
set -u

curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v2.1.1/aqua-installer
echo "c2af02bdd15da6794f9c98db40332c804224930212f553a805425441f8331665  aqua-installer" | sha256sum -c
chmod +x aqua-installer
./aqua-installer
rm ./aqua-installer
# temporary add to PATH (add to PATH in zshrc for permanent configuration)
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua"
ln -s ./aqua/aqua.yaml "${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml"
# set to global config
export AQUA_GLOBAL_CONFIG=${AQUA_GLOBAL_CONFIG:-}:${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml
aqua i -a
# add krew plugin path after krew installed
export PATH="${HOME}/.krew/bin:$PATH"
# gh should be installed via aqua
if hash gh 2>/dev/null; then
    gh config set editor vim
fi
# kubectl & krew should be installed via aqua
if hash kubectl 2>/dev/null; then
    if hash krew 2>/dev/null; then
        # install krew to kubectl
        krew install krew
        kubectl krew install ctx \
            ns \
            access-matrix \
            tree \
            neat \
            resource-capacity \
            view-allocations \
            iexec
    else
        echo_red "krew cannot be found. abort installing krew plugins"
    fi
fi
