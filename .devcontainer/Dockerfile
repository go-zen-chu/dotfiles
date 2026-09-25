# Devcontainer image that reproduces the Ubuntu environment built by install.sh.
# Only the prerequisites that install.sh cannot do non-interactively live here
# (non-root user with passwordless sudo, Homebrew); all tools and configs are
# installed by install.sh itself via .devcontainer/post-create.sh.
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

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
