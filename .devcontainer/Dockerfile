# Devcontainer image that reproduces the Ubuntu environment built by install.sh.
# install.sh runs at build time, so containers created from this image start
# with every tool installed. Build context is the repository root.
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

LABEL org.opencontainers.image.source=https://github.com/go-zen-chu/dotfiles

ARG USERNAME=vscode

# Homebrew (Linux) prerequisites: https://docs.brew.sh/Homebrew-on-Linux#requirements
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        build-essential procps curl file git ncurses-bin locales \
    && locale-gen en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Homebrew refuses to run as root, so install it as the devcontainer user.
USER ${USERNAME}
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    && /home/linuxbrew/.linuxbrew/bin/brew --version

ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH} \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    HOMEBREW_NO_ENV_HINTS=1 \
    LANG=en_US.UTF-8 \
    DEVCONTAINER=true

# Install Homebrew packages in their own layer so it stays cached
# while only scripts / configs change (install.sh then finds them installed).
# HOMEBREW_DOTFILES_* must match what install.sh passes (not CI, not personal mode).
COPY --chown=${USERNAME}:${USERNAME} Brewfile /home/${USERNAME}/dotfiles/Brewfile
WORKDIR /home/${USERNAME}/dotfiles
RUN HOMEBREW_DOTFILES_CI=false HOMEBREW_DOTFILES_PERSONAL=false brew bundle install --file=./Brewfile --no-upgrade \
    && brew cleanup --prune=all \
    && rm -rf "${HOME}/.cache/Homebrew"

# install.sh and .zshrc expect the repository at ~/dotfiles
COPY --chown=${USERNAME}:${USERNAME} . /home/${USERNAME}/dotfiles
RUN TERM=xterm-256color ./install.sh \
    && brew cleanup --prune=all \
    && go clean -cache -modcache \
    && rm -rf "${HOME}/.cache/Homebrew" "${HOME}/.npm"

WORKDIR /home/${USERNAME}
