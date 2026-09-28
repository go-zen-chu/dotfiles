#!/bin/bash
# Per-user setup that cannot be baked into the image. Run as postCreateCommand
# from the workspace folder: bash ~/dotfiles/.devcontainer/post-create.sh
set -eu

# Bind-mounted workspace may be owned by a different uid than the container user.
if git -C "$(pwd)" rev-parse --git-dir >/dev/null 2>&1; then
    git config --global --add safe.directory "$(pwd)"
fi

if [ -n "${GIT_EMAIL:-}" ]; then
    git config --global user.email "${GIT_EMAIL}"
elif [ -z "$(git config --global user.email || true)" ]; then
    echo "[post-create] WARN: git user.email is not set. Set GIT_EMAIL on the host or run 'git config --global user.email ...'" >&2
fi

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
