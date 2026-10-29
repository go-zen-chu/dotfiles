#!/bin/bash
# Configures the installed tools with their own commands (the config files are deployed by chezmoi).
# The chezmoi script home/.chezmoiscripts/run_onchange_after_20-setup-tools.sh.tmpl runs it
# after the dotfiles are applied, and again when this script changes.
# usage: ./scripts/setup-tools.sh [-p (personal mode)] (run from the repository root)

set -eu

# shellcheck source=scripts/log.sh
source ./scripts/log.sh
# shellcheck source=scripts/env.sh
source ./scripts/env.sh

flg_personal_mode="false"
os=$(check_os)
is_ci=$(check_ci)
is_devcontainer=$(check_devcontainer)
home_dir="${HOME}"
python_version="3.13"

# setup_git removes the git settings that older versions of install.sh wrote to ~/.gitconfig.
# The settings are deployed to ~/.config/git/config by chezmoi now.
setup_git() {
    echo_blue "Setup git..."
    # TIPS: `git config --global` writes to ~/.config/git/config (deployed by chezmoi) when ~/.gitconfig
    # does not exist, so edit ~/.gitconfig explicitly
    local legacy_config="${home_dir}/.gitconfig"
    if [ ! -f "${legacy_config}" ]; then
        return
    fi
    # commit signing with ~/.ssh keys was dropped
    git config --file "${legacy_config}" --unset user.signingkey || true
    # TIPS: ~/.gitconfig is read after ~/.config/git/config, so stale values there would override chezmoi's.
    # Only the values pointing at this repository or the gitleaks hooks are removed (exit code 5 = no match).
    git config --file "${legacy_config}" --unset-all include.path '/dotfiles/(terminal-tools/)?git/\.gitconfig$' || true
    git config --file "${legacy_config}" --unset-all core.excludesfile '/dotfiles/(terminal-tools/)?git/global-ignore$' || true
    git config --file "${legacy_config}" --unset-all core.hooksPath '/gitleaks-global-hooks$' || true
}

# setup_gh sets the editor of gh.
setup_gh() {
    echo_blue "Setup gh..."
    gh config set editor vim
}

# setup_python installs the python version used by default with uv.
setup_python() {
    echo_blue "Setup python..."
    # TIPS: installing a Python toolchain takes time in CI so skip there
    if [ "${is_ci}" = "true" ]; then
        return
    fi
    uv python install "${python_version}"
}

# setup_atuin imports the shell history to atuin and logs in to sync it on personal machines.
setup_atuin() {
    echo_blue "Setup atuin..."
    if [ "${flg_personal_mode}" = "false" ] || [ "${is_ci}" = "true" ]; then
        return
    fi
    # TIPS: in CI, .bash_history does not exist which causes an error
    atuin import auto
    atuin login || log "$LOG_LEVEL_WARN" "atuin login failed. run 'atuin login' later"
}

# setup_login_shell makes zsh the login shell.
setup_login_shell() {
    echo_blue "Setup login shell..."
    if [ "${os}" = "termux" ]; then
        # termux has no /etc/shells and sudo, its chsh changes the shell of termux sessions
        if [ "$(basename "${SHELL-}")" != "zsh" ]; then
            chsh -s zsh
        fi
        return
    fi

    local zsh_path
    zsh_path="$(brew --prefix)/bin/zsh"
    if [ ! -e "${zsh_path}" ] || grep -qxF "${zsh_path}" /etc/shells; then
        return
    fi
    echo "${zsh_path}" | sudo tee -a /etc/shells
    if [ "${is_devcontainer}" = "true" ]; then
        # no password is set for the container user, but sudo is passwordless
        sudo chsh -s "${zsh_path}" "$(whoami)"
    elif [ "${is_ci}" = "false" ]; then
        chsh -s "${zsh_path}"
    else
        log "$LOG_LEVEL_INFO" "skip chsh for CI because it has no password given"
    fi
}

# setup_zsh_plugins checks out the zsh plugins, which are git submodules of this repository.
setup_zsh_plugins() {
    echo_blue "Setup zsh plugins..."
    # devcontainer image build copies the repo without .git, submodules are already checked out
    if [ -f .gitmodules ] && git rev-parse --git-dir >/dev/null 2>&1; then
        git submodule update --init --recursive
    fi
}

# setup_vim_plugins installs the vim plugins listed in terminal-tools/vim/plugins.vim with vim-plug.
setup_vim_plugins() {
    echo_blue "Setup vim plugins..."
    # TIPS: installing vim plugins takes time in CI so skip there
    if [ "${is_ci}" = "true" ]; then
        return
    fi
    local plug_path="${home_dir}/.vim/autoload/plug.vim"
    if [ ! -f "${plug_path}" ]; then
        curl -fLo "${plug_path}" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    # TIPS: vim exits non-zero in headless mode because some plugin settings may error there,
    # so check the result by the plugin directory instead of the exit code
    vim -es -u "${home_dir}/.vimrc" -i NONE -c 'PlugInstall --sync' -c 'qa' || true
    if [ ! -d "${home_dir}/.vim/plugged" ]; then
        log "$LOG_LEVEL_WARN" "failed to install vim plugins. run ':PlugInstall' in vim"
    fi
}

# startup parses the options of this script.
startup() {
    local OPTIND opt
    while getopts "p" opt; do
        case $opt in
        "p") flg_personal_mode="true" ;;
        *)
            echo "Usage: $(basename "$0") [-p (personal mode)]" 1>&2
            exit 1
            ;;
        esac
    done
    init_log "$LOG_LEVEL_INFO"
}

startup "$@"

case "${os}" in
"macos" | "ubuntu")
    setup_gh
    setup_python
    setup_atuin
    ;;
"termux") ;;
*)
    log "$LOG_LEVEL_ERROR" "Unsupported OS: ${os}"
    exit 1
    ;;
esac
setup_git
setup_login_shell
setup_zsh_plugins
setup_vim_plugins
