#!/usr/bin/env bash
set -euo pipefail

gitleaks git --pre-commit --no-banner
