#!/bin/bash

set -eu

source ./scripts/log.sh
source ./scripts/env.sh
source ./os-macos/setup.sh

flg_verbose="false"
flg_personal_mode="false"
arg_git_email=""

log_level=$LOG_LEVEL_INFO
os=""
home_dir="${HOME}"
config_dir="${home_dir}/.config"
is_ci="false"
homebrew_bin_path="/undefined"

pyenv_python_version="3.13"
goenv_go_version="1.23"

### setup methods

startup() {
    log "$LOG_LEVEL_INFO" "Start dotfile install script"
    cmdname=$(basename "$0")

    local OPTIND
    while getopts "vpe:" opt; do
        case $opt in
        "e") arg_git_email="$OPTARG" ;;
        "v") flg_verbose="true" ;;
        "p") flg_personal_mode="true" ;;
        *)
            echo "Usage: $cmdname [-e (git email)] [-v (verbose)] [-p (personal mode)]" 1>&2
            exit 0
            ;;
        esac
    done

    if [ "$flg_verbose" = "true" ]; then
        log_level=$LOG_LEVEL_DEBUG
    else
        log_level=$LOG_LEVEL_INFO
    fi
    init_log "$log_level"

    if [ -z "$arg_git_email" ]; then
        log "$LOG_LEVEL_ERROR" "-e option (git email) is required"
    fi

    check_env

    if [[ "${os}" == unsupported* ]]; then
        log "$LOG_LEVEL_ERROR" "Unsupported OS: ${os}"
        exit 1
    fi
}

check_env() {
    echo_blue "Checking environment..."

    os=$(check_os)
    is_ci=$(check_ci)
    echo "OS            : ${os}"
    echo "CPU           : $(check_cpu_arch)"
    echo "Bash Version  : ${BASH_VERSION}"
    echo "User          : $(check_current_user)"
    echo "HOME          : ${home_dir}"
    echo "Config Dir    : ${config_dir}"
    echo "Is CI         : ${is_ci}"
    echo "Log level     : $(get_log_level "$log_level")"
}

setup_package_manager() {
    echo_blue "Setup package manager..."

    if ! hash brew 2>/dev/null; then
        log "$LOG_LEVEL_INFO" "[ ] Homebrew not installed. Installing..."
        if [ "$is_ci" = "true" ]; then
            export NONINTERACTIVE=1
        fi
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        export PATH=$homebrew_bin_path:$PATH

        unset NONINTERACTIVE
        brew update
    else
        log "$LOG_LEVEL_INFO" "[✓] Homebrew installed"
    fi
}

brew_install() {
    if [ -f "${homebrew_bin_path}/$1" ]; then
        log "$LOG_LEVEL_INFO" "[✓] $1 installed (path: ${homebrew_bin_path}/$1)"
        return
    elif [ -d "$(brew --prefix "$1")" ] 2>/dev/null; then
        log "$LOG_LEVEL_INFO" "[✓] $1 installed (path: $(brew --prefix "$1"))"
        return
    fi
    log "$LOG_LEVEL_INFO" "[ ] $1 not installed (homebrew). Installing..."
    brew install "$1"
    log "$LOG_LEVEL_INFO" "[✓] $1 install finished"
}

setup_basic_tools() {
    echo_blue "Setup basic tools..."

    setup_git
    setup_anyenv

    # TIPS: installing tools with Homebrew takes a long time in CI so skip for these tools
    if [ "${is_ci}" = "false" ]; then
        setup_gh
        brew_install gibo
        brew_install ghq

        # terminal tools
        brew_install openssl
        brew_install wget
        brew_install rsync
        brew_install fzf
        brew_install jq
        brew_install yq
        brew_install tree
        brew_install shellcheck
        brew_install terraform
        brew_install ansible
        setup_direnv

        # golang related tools
        brew_install mage
        brew_install golangci-lint

        # language tools
        setup_node

        # kubernetes tools
        brew_install kubectl
        brew_install kustomize
        brew_install k9s
        setup_krew
    fi

    if [ $# -eq 1 ]; then
        local setup_os_specific_func=$1
        $setup_os_specific_func
    fi
}

setup_git() {
    echo_blue "Setup git..."

    brew_install git
    # in first install global config is not created
    touch "${home_dir}/.gitconfig"

    local git_config_global_result
    git_config_global_result="$(git config --global --list)"

    if [ -z "${git_config_global_result}" ]; then
        git config --global user.name "Akira Masuda"
        git config --global user.email "${arg_git_email}"
        git config --global core.excludesfile "${home_dir}/dotfiles/git/global-ignore"
        git config --global push.default current
        git config --global pull.rebase false
    fi
}

setup_gh() {
    echo_blue "Setup gh..."

    brew_install gh
    gh config set editor vim
}

setup_direnv() {
    echo_blue "Setup direnv..."

    brew_install direnv

    local direnv_config_path
    direnv_config_path="${config_dir}/direnv"
    mkdir -p "${direnv_config_path}"
    if [ ! -f "${direnv_config_path}/direnv.toml" ]; then
        cat <<EOF >"${direnv_config_path}/direnv.toml"
[global]
load_dotenv = true
EOF
    fi
}

setup_anyenv() {
    echo_blue "Setup anyenv..."

    brew_install anyenv

    log "$LOG_LEVEL_INFO" "anyenv initializing..."
    anyenv init
    log "$LOG_LEVEL_INFO" "eval anyenv..."
    eval "$(anyenv init -)"
    log "$LOG_LEVEL_INFO" "pyenv initializing..."
    anyenv install pyenv
    log "$LOG_LEVEL_INFO" "goenv initializing..."
    anyenv install goenv

    # for loading xenv things with new child process. `exec $SHELL -l` will replace current shell process
    $SHELL -l

    cd /home/am/.anyenv/envs/pyenv/plugins/python-build/../.. && git pull && cd -
    cd "${HOME}/.anyenv/envs/goenv/plugins/go-build/../.." && git pull && cd -

    pyenv install "${pyenv_python_version}"
    pyenv global "${pyenv_python_version}"
    pyenv rehash

    goenv install "${goenv_go_version}"
    goenv global "${goenv_go_version}"
    goenv init
}

setup_node() {
    echo_blue "Setup node..."

    brew_install "node@22"
    local node_path
    node_path="$(brew --prefix node@22)/bin"
    export PATH="${node_path}:$PATH"

    npm install -g pnpm
    npm install -g typescript
    npm install -g bash-language-server
}

setup_krew() {
    echo_blue "Setup krew..."

    brew_install krew

    # local krew_path
    # krew_path="$(brew --prefix krew)/bin"
    # export PATH="${home_dir}/.krew/bin:${krew_path}:$PATH"
    export PATH="${home_dir}/.krew/bin:$PATH"
    kubectl krew update
    kubectl krew install ctx \
        ns \
        access-matrix \
        tree \
        neat \
        resource-capacity \
        view-allocations \
        iexec \
        stern
}

setup_personal_machine_tools() {
    if [ "$flg_personal_mode" = "false" ]; then
        echo_blue "Skip setup personal machine tools"
        return
    fi
    echo_blue "Setup personal machine tools..."

    if [ "${is_ci}" = "false" ]; then
        brew_install hugo
        brew_install sass/sass/sass
    fi

    if [ $# -eq 1 ]; then
        local setup_os_specific_func=$1
        $setup_os_specific_func
    fi
}

setup_zsh() {
    echo_blue "Setup zsh..."

    # make sure install zsh plugins
    git submodule update --init --recursive
    brew_install zsh
    local zsh_path="${homebrew_bin_path}/zsh"

    # change default shell
    if [ -e "${zsh_path}" ] && ! grep "${zsh_path}" "/etc/shells"; then
        echo "${zsh_path}" | sudo tee -a /etc/shells
        chsh -s "${zsh_path}"
    fi

    # configure
    if [ -f "${home_dir}/local.zsh" ]; then
        cp ./zsh/local.zsh "${home_dir}"
    fi
    local local_zshrc_path="${home_dir}/.zshrc"
    if [ -f "${local_zshrc_path}" ] && ! diff "${local_zshrc_path}" ./zsh/local.zsh >/dev/null 2>&1; then
        cp "${local_zshrc_path}" "${local_zshrc_path}.$(date '+%Y%m%d-%H%M%S').bk"
    fi
    cp -f ./zsh/.zshrc "${home_dir}"
}

setup_vim() {
    echo_blue "Setup vim..."

    brew_install vim
    local vimrc_path="${home_dir}/.vimrc"

    # configure
    if [ ! -d "${home_dir}/.vim" ]; then
        # make and copy all things inside .vim
        cp -r ./vim/.vim "${home_dir}"
    fi
    if [ -f "${vimrc_path}" ] && ! diff "${vimrc_path}" ./vim/.vimrc >/dev/null 2>&1; then
        cp "${vimrc_path}" "${vimrc_path}.$(date '+%Y%m%d-%H%M%S').bk"
    fi
    cp -f ./vim/.vimrc "${home_dir}"
}

setup_tmux() {
    echo_blue "Setup tmux..."

    brew_install tmux

    # configure
    local tmux_conf_path="${home_dir}/.tmux.conf"
    if [ -f "${tmux_conf_path}" ] && ! diff "${tmux_conf_path}" ./tmux/.tmux.conf >/dev/null 2>&1; then
        cp "${tmux_conf_path}" "${tmux_conf_path}.$(date '+%Y%m%d-%H%M%S').bk"
    fi
    cp -f ./tmux/.tmux.conf "${home_dir}"

    if [ ! -d "${home_dir}/.tmux/plugins/tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm "${home_dir}/.tmux/plugins/tpm"
    fi

    echo_green "[IMPORTANT] Make sure to run ctrl+b ctrl+I for installing tmux plugins"
}

### install

startup "$@" # parse arguments given to this script

case "${os}" in
"macos")
    macos_check_developer_tool
    macos_setup_defaults

    homebrew_bin_path="/opt/homebrew/bin"
    setup_package_manager
    setup_basic_tools macos_setup_basic_tools
    setup_personal_machine_tools macos_setup_personal_machine_tools
    setup_zsh
    setup_vim
    setup_tmux
    ;;
"ubuntu")
    homebrew_bin_path="/home/linuxbrew/.linuxbrew/bin"
    setup_package_manager
    setup_basic_tools
    setup_personal_machine_tools
    setup_zsh
    setup_vim
    setup_tmux
    ;;
esac

echo_green "setup finished successfully!"
log "$LOG_LEVEL_INFO" "done"
