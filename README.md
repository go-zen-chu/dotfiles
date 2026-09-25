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

`.devcontainer/` reproduces the Ubuntu environment in a container.
The image only prepares a non-root user and Homebrew; `install.sh` is run by `postCreateCommand`
(`.devcontainer/post-create.sh`), so the container gets the same tools and configs as a real machine.

- The repository is mounted at `~/dotfiles` because configs (e.g. `.zshrc`) refer to that path.
- Git email is taken from `GIT_EMAIL` on the host, or from the host `~/.gitconfig` that the devcontainer copies in.
- Commit signing uses the key from the forwarded ssh-agent when `~/.ssh/id_ed25519.pub` is not in the container.
- Homebrew packages are kept in the `dotfiles-linuxbrew` volume, so rebuilding the container is fast after the first run.
- Personal mode (`-p`) is not supported because it needs interactive login / snap.

```bash
# VS Code: "Dev Containers: Reopen in Container"
# CLI:
GIT_EMAIL="your git email here" devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . zsh
```

### Backup config & secrets

```bash
cd $HOME/dotfiles
./backup.sh -p "path/to/cloudstorage"
```
