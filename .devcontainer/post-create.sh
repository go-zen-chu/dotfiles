#!/bin/bash
# Runs install.sh inside the devcontainer (postCreateCommand).
set -eu

cd "$(dirname "$0")/.."

# Bind-mounted workspace may be owned by a different uid than the container user.
git config --global --add safe.directory "$(pwd)"

git_email="${GIT_EMAIL:-$(git config --global user.email || true)}"
if [ -z "${git_email}" ]; then
    echo "[post-create] git email not found. Set GIT_EMAIL on the host or user.email in your host ~/.gitconfig" >&2
    exit 1
fi

./install.sh -e "${git_email}"

# install.sh points user.signingkey at ~/.ssh/id_ed25519.pub, which does not exist
# in the container. Use the key from the forwarded ssh-agent instead so that
# commit.gpgsign (terminal-tools/git/.gitconfig) keeps working.
signing_key="$(git config --global user.signingkey || true)"
if [ ! -f "${signing_key}" ]; then
    agent_key="$(ssh-add -L 2>/dev/null | grep -m1 -E '^(ssh-|ecdsa-|sk-)' || true)"
    if [ -n "${agent_key}" ]; then
        git config --global user.signingkey "key::${agent_key}"
        echo "[post-create] user.signingkey set from ssh-agent"
    else
        echo "[post-create] WARN: no ssh key for commit signing (${signing_key}). Forward your ssh-agent or run 'git config --global commit.gpgsign false'" >&2
    fi
fi
