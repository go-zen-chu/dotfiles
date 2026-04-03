# dotfiles

[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-installer.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-installer.yml)
[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-downloader.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-downloader.yml)
[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-backup.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-backup.yml)
[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-chezmoi.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-chezmoi.yml)

Supported OS

- MacOS
- Ubuntu

My configuration files for DRY. CI is performed on GitHub Actions.

## How to use

### Setup a new machine

```bash
# run downloader.sh for downloading latest dotfiles (using git command)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/go-zen-chu/dotfiles/refs/heads/master/downloader.sh)"

# install dotfiles
./install.sh -e "your git email here"
```

### Manage dotfiles with chezmoi

[chezmoi](https://www.chezmoi.io/) is supported for applying and updating dotfiles automatically.

```bash
# Initialize chezmoi with this dotfiles repo and apply managed dotfiles
chezmoi init go-zen-chu

# Apply the latest dotfiles to your home directory
chezmoi apply

# Pull latest changes from the repo and re-apply (update workflow)
chezmoi update
```

The chezmoi-managed dotfiles live in the `home/` directory of this repo.
When chezmoi is initialized, it reads `.chezmoiroot` to locate the source state in `home/`.

### Backup config & secrets

```bash
cd $HOME/dotfiles
./backup.sh -p "path/to/cloudstorage"
```
