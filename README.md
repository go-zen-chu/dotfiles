# dotfiles

[![Actions Status](https://github.com/go-zen-chu/dotfiles/workflows/CI/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions)

My configuration files for DRY. CI is performed on GitHub Actions.

## How to use

### Setup a new machine

```bash
# clone with submodules
git clone --recursive git@github.com:go-zen-chu/dotfiles.git

# check what use can install
make help
# setup all for mac
make setup-mac
# setup all for personal mac
make setup-mac-personal
# setup all for archlinux
make setup-arch
# setup only vim
make vim
```

### Backup config

```bash
make backup
```

## Supported OS

- MacOS
- ArchLinux
