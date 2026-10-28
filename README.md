# dotfiles

[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-installer.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-installer.yml)
[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-downloader.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-downloader.yml)
[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-backup.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-backup.yml)

Supported OS

- MacOS
- Ubuntu
- Termux (installs only a small set of tools with `pkg`, see [os-termux/setup.sh](./os-termux/setup.sh); dotfiles are applied with chezmoi as well)
- Windows (see [os-windows/README.md](./os-windows/README.md))

My configuration files for DRY. CI is performed on GitHub Actions.

## How to use

### Setup a new machine

```bash
# run downloader.sh for downloading latest dotfiles (using git command)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/go-zen-chu/dotfiles/refs/heads/master/downloader.sh)"

# install dotfiles (add -p for personal mode)
./install.sh -e "your git email here"
```

`install.sh` installs Homebrew (pkg on termux) and [chezmoi](https://www.chezmoi.io/), then applies the dotfiles with chezmoi.

| Path | Managed by | Content |
| --- | --- | --- |
| `Brewfile` | `brew bundle` | Homebrew formulae / casks, `go install` and krew plugins for macOS / Ubuntu |
| `home/` | chezmoi | files deployed to `$HOME` (mostly symlinks to `terminal-tools/` and `os-macos/`) |
| `home/.chezmoiscripts/` | chezmoi | run `scripts/install-packages.sh`, `scripts/setup-tools.sh` and the macOS defaults when they (or the Brewfile) change |
| `os-termux/setup.sh` | pkg | packages for termux |

Files that chezmoi overwrites on the first run are moved to `<path>.<date>.bk`.

### Update the environment

```bash
cd ~/dotfiles
# pull the repository, apply the dotfiles and upgrade every package
# (on a TTY, it also asks whether to uninstall the packages that are not in the Brewfile)
./install.sh -u -e "your git email here"

# only apply the dotfiles (the chezmoi scripts install packages added to the Brewfile)
chezmoi update
```

### Check drift

```bash
chezmoi status                               # files in $HOME that differ from home/
brew bundle check --file ~/dotfiles/Brewfile    # packages in the Brewfile that are not installed
brew bundle cleanup --file ~/dotfiles/Brewfile  # installed packages that are not in the Brewfile
```

### Termux

```bash
pkg install -y git
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/go-zen-chu/dotfiles/refs/heads/master/downloader.sh)"
cd ~/dotfiles && ./install.sh -e "your git email here"
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
  git email from `GIT_EMAIL` on the host.
- The dotfiles are at `~/dotfiles` in the image. To pick up dotfiles changes, pull the new image and rebuild the container.
- `.devcontainer/` in this repository builds the image locally, for testing changes to `install.sh`.
- Personal mode (`-p`) is not supported because it needs interactive login / snap.

### CI

`.github/workflows/check-installer.yml` runs the installer on macOS / Ubuntu and checks the Windows setup.
On PRs only the jobs of the OS affected by the changed files run
(e.g. `os-windows/**` only runs the Windows job, `install.sh` runs macOS and Ubuntu).
winget is not available on GitHub-hosted runners, so the Windows job lints the scripts,
checks the package IDs in `os-windows/winget-packages.txt` exist and installs the profile.

### Backup config & secrets

```bash
cd $HOME/dotfiles
./backup.sh -p "path/to/cloudstorage"
```
