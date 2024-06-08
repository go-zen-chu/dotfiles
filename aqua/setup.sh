#!/usr/bin/env bash
set -u

if hash aqua 2>/dev/null; then
    curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v2.3.0/aqua-installer
    echo "1577b99b74751a5ddeea757198cee3b600fce3ef18990540e4d0e667edcf1b5f  aqua-installer" | sha256sum -c
    chmod +x aqua-installer
    ./aqua-installer
    rm ./aqua-installer
fi
# temporary add to PATH (add to PATH in zshrc for permanent configuration)
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua"
# create hard link (not symbolic link)
rm "${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml"
ln ./aqua/aqua.yaml "${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml"
# set to global config
export AQUA_GLOBAL_CONFIG=${AQUA_GLOBAL_CONFIG:-}:${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml
aqua i -a

##### Initial setting for installed tools #####

# add krew plugin path after krew installed
export PATH="${HOME}/.krew/bin:$PATH"
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
            iexec \
            stern
    else
        echo_red "krew cannot be found. abort installing krew plugins"
    fi
fi

# gh should be installed via aqua
if hash gh 2>/dev/null; then
    gh config set editor vim
fi

# direnv configuration
if hash direnv 2>/dev/null; then
    direnv_config_path="${XDG_CONFIG_HOME:-$HOME/.config}/direnv"
    mkdir -p "${direnv_config_path}"
    if [ ! -f "${direnv_config_path}/direnv.toml" ]; then
        cat <<EOF >"${direnv_config_path}/direnv.toml"
[global]
load_dotenv = true
EOF
    fi
fi
