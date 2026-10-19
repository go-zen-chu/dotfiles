# dotfiles

[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-installer.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-installer.yml)
[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-downloader.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-downloader.yml)
[![Actions Status](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-backup.yml/badge.svg)](https://github.com/go-zen-chu/dotfiles/actions/workflows/check-backup.yml)

Supported OS

- MacOS
- Ubuntu
- Termux (installs only a small set of tools with `pkg`, see [os-termux/setup.sh](./os-termux/setup.sh))
- Windows (see [os-windows/README.md](./os-windows/README.md))

My configuration files for DRY. CI is performed on GitHub Actions.

## How to use

### Setup a new machine

```bash
# run downloader.sh for downloading latest dotfiles (using git command)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/go-zen-chu/dotfiles/refs/heads/master/downloader.sh)"

# install dotfiles
./install.sh -e "your git email here"
```

### Termux

```bash
pkg install -y git
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/go-zen-chu/dotfiles/refs/heads/master/downloader.sh)"
cd ~/dotfiles && ./install.sh -e "your git email here"
```

### Check drift

Packages installed by `install.sh` are listed in [packages.yaml](./packages.yaml) per package manager,
with the conditions (`os`, `personal`, `ci`, `exclude`) and the reason (`description`) of each package.
Tools added by hand or left over from old setups drift the environment from it, which leaves unmanaged (and unpatched) tools behind.

```bash
# only report the drift (add -p for personal mode)
./install.sh --check-drift
```

- Packages: `missing` (in packages.yaml but not installed) and `extra` (installed on request but not in packages.yaml)
  for Homebrew formulae / casks, `go install`, `npm -g` and krew plugins.
  Versions are ignored: names are compared without the version suffix (`node@24` is satisfied by `node@22`).
- Config: `~/dotfiles` is on an up-to-date master without local changes, `~/.zshrc`, the login shell and the global git config point to the repository.
- The exit status is a bitmask: `1` missing packages, `2` extra packages, `4` config drift.
- packages.yaml is read with [yq](https://github.com/mikefarah/yq), which `install.sh` installs with Homebrew first.

`./install.sh` without `--check-drift` also reports the drift after installing Homebrew and yq, then installs the missing packages (extra packages are left as they are).
To add a tool, add it to `packages.yaml` instead of `install.sh`.
Termux is not checked because it installs its own small set of tools with `pkg` (`os-termux/setup.sh`).

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
