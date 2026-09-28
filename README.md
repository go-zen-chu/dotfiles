# dotfiles

[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-installer.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-installer.yml)
[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-downloader.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-downloader.yml)
[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-backup.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-backup.yml)

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

### Devcontainer

`ghcr.io/go-zen-chu/dotfiles-devcontainer` is an Ubuntu image with `install.sh` already applied
(built by `.github/workflows/devcontainer-image.yml` for amd64 / arm64).
Containers start without running the installer, so it can be used in any repository.

```bash
# use the environment in another repository
cp -r ~/dotfiles/devcontainer-template/.devcontainer path/to/repo/
```

- `postCreateCommand` only does per-user setup (`.devcontainer/post-create.sh`):
  git email from `GIT_EMAIL` on the host, and commit signing with the key from the forwarded ssh-agent.
- The dotfiles are at `~/dotfiles` in the image. To pick up dotfiles changes, pull the new image and rebuild the container.
- `.devcontainer/` in this repository builds the image locally, for testing changes to `install.sh`.
- Personal mode (`-p`) is not supported because it needs interactive login / snap.

### Backup config & secrets

```bash
cd $HOME/dotfiles
./backup.sh -p "path/to/cloudstorage"
```
