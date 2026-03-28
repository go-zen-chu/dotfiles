# dotfiles

[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-installer.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-installer.yml)
[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-downloader.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-downloader.yml)
[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-backup.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-backup.yml)

Supported OS

- MacOS
- Ubuntu

Nix support

- Experimental `flake + home-manager` support is available.
- `nix-darwin` support is being added for macOS system defaults and Karabiner config placement.
- Current scope focuses on CLI tools, shell, git, Atuin, Starship, Zellij, and macOS host setup.
- Raycast, iTerm2, Tampermonkey import, and Windows full automation are not migrated yet.

My configuration files for DRY. CI is performed on GitHub Actions.

## How to use

### Setup a new machine

```bash
# run downloader.sh for downloading latest dotfiles (using git command)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/go-zen-chu/dotfiles/refs/heads/master/downloader.sh)"

# install dotfiles
./install.sh -e "your git email here"
```

### Setup with Nix (experimental)

```bash
cd $HOME/dotfiles

# Linux
nix run github:nix-community/home-manager -- switch --flake .#am-linux

# macOS (Apple Silicon, home-manager only)
nix run github:nix-community/home-manager -- switch --flake .#am-darwin

# macOS (Intel, home-manager only)
nix run github:nix-community/home-manager -- switch --flake .#am-darwin-intel

# macOS (Apple Silicon, nix-darwin)
nix run github:LnL7/nix-darwin -- switch --flake .#am-darwin

# macOS (Intel, nix-darwin)
nix run github:LnL7/nix-darwin -- switch --flake .#am-darwin-intel
```

Notes:

- `nix-darwin` is the preferred path for macOS because it can manage system defaults in addition to Home Manager.
- This path currently does not replace `install.sh` yet.
- Git identity, SSH keys, Tailscale login, Atuin login, and other secrets/auth flows remain manual.
- Windows files remain in this repository, but there is no Home Manager profile for Windows yet.

### Backup config & secrets

```bash
cd $HOME/dotfiles
./backup.sh -p "path/to/cloudstorage"
```
