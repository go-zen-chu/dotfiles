# dotfiles

[![Actions Status](https://github.com/go-zen-chu/dotfiles/workflows/CI/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions)

| Supported OS |
| ------------ |
| MacOS |
| Ubuntu |

My configuration files for DRY. CI is performed on GitHub Actions.

## How to use

### Setup a new machine

```bash
# run downloader.sh for downloading latest dotfiles without git
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/go-zen-chu/dotfiles/refs/heads/master/downloader.sh)"

# install dotfiles
./install.sh -e "your git email here"
```

### Backup config

```bash
# TBD
```

