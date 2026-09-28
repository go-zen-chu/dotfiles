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
    LANG=en_US.UTF-8 \
    DEVCONTAINER=true

# install.sh and .zshrc expect the repository at ~/dotfiles
COPY --chown=${USERNAME}:${USERNAME} . /home/${USERNAME}/dotfiles
WORKDIR /home/${USERNAME}/dotfiles
RUN TERM=xterm-256color ./install.sh \
    && brew cleanup --prune=all \
    && go clean -cache -modcache \
    && rm -rf "${HOME}/.cache/Homebrew" "${HOME}/.npm"

WORKDIR /home/${USERNAME}
