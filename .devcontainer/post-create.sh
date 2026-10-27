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
