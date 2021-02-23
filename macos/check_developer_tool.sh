#!/usr/bin/env bash
set -u

echo "[INFO] Checking developer tools"
# if installed returns 0 else install
if ! xcode-select -p ; then
  xcode-select --install
else
  echo "developer tool is already installed"
fi
