#!/bin/bash

set -eu

# shellcheck source=scripts/log.sh
source ./scripts/log.sh
# shellcheck source=scripts/env.sh
source ./scripts/env.sh
# shellcheck source=scripts/packages.sh
source ./scripts/packages.sh
# shellcheck source=scripts/drift.sh
source ./scripts/drift.sh
# shellcheck source=os-macos/setup.sh
source ./os-macos/setup.sh
# shellcheck source=os-linux/setup.sh
source ./os-linux/setup.sh
# shellcheck source=os-termux/setup.sh
source ./os-termux/setup.sh

flg_verbose="false"
flg_personal_mode="false"
flg_check_drift="false"
git_user_name="Akira Masuda"
arg_git_email=""

log_level=$LOG_LEVEL_INFO
os=""
home_dir="${HOME}"
config_dir="${home_dir}/.config"
# .zshrc and the global git config read the repository from this path
dotfiles_dir="${home_dir}/dotfiles"
gitleaks_hook_dir="${config_dir}/gitleaks-global-hooks"
package_manifest="./packages.yaml"
selected_packages=""
is_ci="false"
is_devcontainer="false"
homebrew_bin_path="/undefined"

# keep in sync with node@<version> in packages.yaml
nodejs_version="24"
python_version="3.13"

### setup methods

startup() {
    log "$LOG_LEVEL_INFO" "Start dotfile install script"
    cmdname=$(basename "$0")

    # getopts does not support long options, so translate them to short ones
    local arg
    local -a args=()
    for arg in "$@"; do
        case "${arg}" in
        "--check-drift") args+=("-c") ;;
        *) args+=("${arg}") ;;
        esac
    done
    if [ "${#args[@]}" -gt 0 ]; then
        set -- "${args[@]}"
    fi

    local OPTIND
    while getopts "vpce:" opt; do
        case $opt in
        "e") arg_git_email="$OPTARG" ;;
        "v") flg_verbose="true" ;;
        "p") flg_personal_mode="true" ;;
        "c") flg_check_drift="true" ;;
        *)
            echo "Usage: $cmdname [-e (git email)] [-v (verbose)] [-p (personal mode)] [-c|--check-drift (only check drift from packages.yaml)]" 1>&2
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

    check_env

    # devcontainer image is built without a user, so git email is set at container creation
    if [ -z "$arg_git_email" ] && [ "${is_devcontainer}" = "false" ] && [ "${flg_check_drift}" = "false" ]; then
        log "$LOG_LEVEL_ERROR" "-e option (git email) is required"
    fi

    if [[ "${os}" == unsupported* ]]; then
        log "$LOG_LEVEL_ERROR" "Unsupported OS: ${os}"
        exit 1
    fi
}

check_env() {
    echo_blue "Checking environment..."

    os=$(check_os)
    is_ci=$(check_ci)
    is_devcontainer=$(check_devcontainer)
    echo "OS            : ${os}"
    echo "CPU           : $(check_cpu_arch)"
    echo "Bash Version  : ${BASH_VERSION}"
    echo "User          : $(check_current_user)"
    echo "HOME          : ${home_dir}"
    echo "Config Dir    : ${config_dir}"
    echo "Is CI         : ${is_ci}"
    echo "Personal mode : ${flg_personal_mode}"
    echo "Devcontainer  : ${is_devcontainer}"
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
    local tool_name
    tool_name=$1
    if [ -f "${homebrew_bin_path}/${tool_name}" ]; then
        log "$LOG_LEVEL_INFO" "[✓] ${tool_name} installed (path: ${homebrew_bin_path}/${tool_name})"
        return
    elif [ -d "$(brew --prefix "${tool_name}")" ] 2>/dev/null; then
        log "$LOG_LEVEL_INFO" "[✓] ${tool_name} installed (path: $(brew --prefix "${tool_name}"))"
        return
    fi
    log "$LOG_LEVEL_INFO" "[ ] ${tool_name} not installed (homebrew). Installing..."
    brew install "${tool_name}"
    log "$LOG_LEVEL_INFO" "[✓] ${tool_name} install finished"
}

cask_install() {
    local cask_name
    cask_name=$1
    if brew list --cask "${cask_name}" >/dev/null 2>&1; then
        log "$LOG_LEVEL_INFO" "[✓] ${cask_name} installed (cask)"
        return
    fi
    log "$LOG_LEVEL_INFO" "[ ] ${cask_name} not installed (cask). Installing..."
    brew install --cask "${cask_name}"
    log "$LOG_LEVEL_INFO" "[✓] ${cask_name} install finished"
}

go_install() {
    local tool_name
    tool_name=$1
    local tool_url
    tool_url=$2

    if hash "${tool_name}" 2>/dev/null; then
        log "$LOG_LEVEL_INFO" "[✓] ${tool_name} is already installed"
        return
    fi
    log "$LOG_LEVEL_INFO" "[ ] ${tool_name} not installed. Installing..."
    go install "${tool_url}"
    log "$LOG_LEVEL_INFO" "[✓] ${tool_name} install finished"
}

npm_install() {
    local package_name
    package_name=$1
    if npm ls -g --depth=0 "${package_name}" >/dev/null 2>&1; then
        log "$LOG_LEVEL_INFO" "[✓] ${package_name} already installed (npm)"
        return
    fi
    log "$LOG_LEVEL_INFO" "[ ] ${package_name} not installed (npm). Installing..."
    npm install -g "${package_name}"
    log "$LOG_LEVEL_INFO" "[✓] ${package_name} install finished"
}

krew_install() {
    local plugin_name
    plugin_name=$1
    # some plugins are not provided for every platform (e.g. access-matrix on linux/arm64)
    if ! kubectl krew install "${plugin_name}"; then
        log "$LOG_LEVEL_WARN" "failed to install krew plugin: ${plugin_name}"
    fi
}

# install_packages installs the packages of the given manager selected from packages.yaml.
install_packages() {
    local manager=$1
    local entry_manager name src
    # read from fd 3 so that installers reading stdin do not consume the package list
    while IFS=$'\t' read -r -u 3 entry_manager name src; do
        if [ "${entry_manager}" != "${manager}" ]; then
            continue
        fi
        case "${manager}" in
        "brew") brew_install "${name}" ;;
        "cask") cask_install "${name}" ;;
        "go") go_install "${name}" "${src}" ;;
        "npm") npm_install "${name}" ;;
        "krew") krew_install "${name}" ;;
        esac
    done 3<<<"${selected_packages}"
}

# export_tool_paths adds the directories of tools installed by this script to PATH,
# since some of them (keg-only node, krew plugins, go tools) are not on PATH by default.
export_tool_paths() {
    if [ -d "${homebrew_bin_path}" ]; then
        export PATH="${homebrew_bin_path}:$PATH"
    fi
    if hash brew 2>/dev/null; then
        local node_prefix
        node_prefix="$(brew --prefix "node@${nodejs_version}" 2>/dev/null || true)"
        if [ -n "${node_prefix}" ] && [ -d "${node_prefix}/bin" ]; then
            export PATH="${node_prefix}/bin:$PATH"
        fi
    fi
    if hash go 2>/dev/null; then
        local gopath
        gopath="$(go env GOPATH)"
        export PATH="${gopath}/bin:$PATH"
    fi
    export PATH="${home_dir}/.krew/bin:$PATH"
}

# enabled_package_addons prints the addons of packages.yaml enabled by the options (comma separated).
enabled_package_addons() {
    if [ "${flg_personal_mode}" = "true" ]; then
        echo "personal"
    fi
}

# load_packages selects the packages of packages.yaml for this environment.
# It needs yq, which is installed with Homebrew before the other packages.
load_packages() {
    export_tool_paths
    selected_packages=$(select_packages "${package_manifest}" "${os}" "$(check_cpu_arch)" "$(enabled_package_addons)" "${is_ci}")
}

# check_drift reports the drift of the environment from packages.yaml and the dotfiles wiring.
# It returns a bitmask of DRIFT_MISSING, DRIFT_EXTRA and DRIFT_CONFIG (0 when no drift).
check_drift() {
    local status=0
    report_package_drift "${selected_packages}" || status=$?
    report_config_drift "${dotfiles_dir}" "${home_dir}/.zshrc" ./terminal-tools/zsh/.zshrc \
        "${homebrew_bin_path}/zsh" "${gitleaks_hook_dir}" || status=$((status | $?))
    return "${status}"
}

setup_basic_tools() {
    echo_blue "Setup basic tools..."

    install_packages brew
    install_packages cask
    export_tool_paths

    setup_git
    setup_gh
    setup_direnv
    setup_python
    setup_go
    setup_node
    setup_krew
    setup_atuin
    setup_gitleaks
    setup_claude_code

    install_packages go
    install_packages npm
    install_packages krew

    if [ $# -eq 1 ]; then
        local setup_os_specific_func=$1
        $setup_os_specific_func
    fi
}

setup_git() {
    echo_blue "Setup git..."

    configure_git
}

# shared with os-termux/setup.sh
configure_git() {
    # in first install global config is not created
    touch "${home_dir}/.gitconfig"

    # Include repo-managed static config so updates always take effect
    # (the old "only when global config is empty" approach never re-applied changes).
    local repo_gitconfig="${dotfiles_dir}/terminal-tools/git/.gitconfig"
    if ! git config --global --get-all include.path 2>/dev/null | grep -qxF "${repo_gitconfig}"; then
        git config --global --add include.path "${repo_gitconfig}"
    fi

    # Machine/user specific settings (absolute paths can't live in the shared file)
    git config --global core.excludesfile "${dotfiles_dir}/terminal-tools/git/global-ignore"
    git config --global user.signingkey "${home_dir}/.ssh/id_ed25519.pub"
    if [ -z "$(git config --global user.name)" ]; then
        git config --global user.name "${git_user_name}"
    fi
    if [ -z "$(git config --global user.email)" ] && [ -n "${arg_git_email}" ]; then
        git config --global user.email "${arg_git_email}"
    fi
}

setup_gh() {
    echo_blue "Setup gh..."

    gh config set editor vim
}

setup_direnv() {
    echo_blue "Setup direnv..."

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

setup_python() {
    echo_blue "Setup python..."

    # uv manages Python versions and virtualenvs (replaces pyenv/anyenv).
    # TIPS: installing a Python toolchain takes time in CI so skip there
    if [ "${is_ci}" = "false" ]; then
        log "$LOG_LEVEL_INFO" "install python ${python_version} via uv..."
        uv python install "${python_version}"
    fi

    log "$LOG_LEVEL_INFO" "[✓] python setup finished"
}

setup_go() {
    echo_blue "Setup go..."

    # Install Go via Homebrew and rely on Go's built-in toolchain management
    # (GOTOOLCHAIN=auto) so each project auto-fetches the version pinned in its
    # go.mod. This replaces goenv/anyenv.
    export GOTOOLCHAIN=auto
    local gopath
    gopath="$(go env GOPATH)"
    export PATH="${gopath}/bin:$PATH"
}

setup_node() {
    echo_blue "Setup node..."

    local node_path
    node_path="$(brew --prefix node@${nodejs_version})/bin"
    export PATH="${node_path}:$PATH"
}

setup_krew() {
    echo_blue "Setup krew..."

    # local krew_path
    # krew_path="$(brew --prefix krew)/bin"
    # export PATH="${home_dir}/.krew/bin:${krew_path}:$PATH"
    export PATH="${home_dir}/.krew/bin:$PATH"
    kubectl krew update
}

setup_atuin() {
    echo_blue "Setup atuin..."

    if [ "${flg_personal_mode}" = "false" ] || [ "${is_ci}" = "true" ]; then
        return
    fi
    # TIPS: in CI, .bas_history does not exists which cause an error
    atuin import auto
    set +e # ignore error when login failed
    atuin login
    set -e
}

setup_gitleaks() {
    echo_blue "Setup gitleaks..."

    configure_gitleaks_hook
}

# shared with os-termux/setup.sh
configure_gitleaks_hook() {
    mkdir -p "${gitleaks_hook_dir}"
    cp ./terminal-tools/gitleaks/global-pre-commit.sh "${gitleaks_hook_dir}/pre-commit"
    git config --global core.hooksPath "${gitleaks_hook_dir}"

    log "$LOG_LEVEL_INFO" "[✓] gitleaks install finished"
}

setup_claude_code() {
    echo_blue "Setup claude code..."

    mkdir -p "${home_dir}/.claude"

    # apm rejects relative paths at user scope, so resolve an absolute path.
    local apm_pkg_dir
    apm_pkg_dir="$(pwd)/apm"
    apm install "${apm_pkg_dir}" --global --target claude
    apm compile --global

    log "$LOG_LEVEL_INFO" "[✓] claude-code install finished"
}

setup_personal_machine_tools() {
    if [ "$flg_personal_mode" = "false" ]; then
        echo_blue "Skip setup personal machine tools"
        return
    fi
    echo_blue "Setup personal machine tools..."

    if [ $# -eq 1 ]; then
        local setup_os_specific_func=$1
        $setup_os_specific_func
    fi
}

setup_zsh() {
    echo_blue "Setup zsh..."

    local zsh_path="${homebrew_bin_path}/zsh"

    # change default shell
    if [ -e "${zsh_path}" ] && ! grep "${zsh_path}" "/etc/shells"; then
        echo "${zsh_path}" | sudo tee -a /etc/shells
        if [ "${is_devcontainer}" = "true" ]; then
            # no password is set for the container user, but sudo is passwordless
            log "$LOG_LEVEL_INFO" "running chsh with sudo for devcontainer..."
            sudo chsh -s "${zsh_path}" "$(whoami)"
        elif [ "${is_ci}" = "false" ]; then
            log "$LOG_LEVEL_INFO" "running chsh..."
            chsh -s "${zsh_path}"
        else
            log "$LOG_LEVEL_INFO" "skip chsh for CI because it has no password given"
        fi
    fi

    deploy_zsh_config
}

# shared with os-termux/setup.sh
deploy_zsh_config() {
    # make sure install zsh plugins
    # (devcontainer image build copies the repo without .git, submodules are already checked out)
    if git rev-parse --git-dir >/dev/null 2>&1; then
        git submodule update --init --recursive
    fi
    if [ ! -f "${home_dir}/local.zsh" ]; then
        cp ./terminal-tools/zsh/local.zsh "${home_dir}"
    fi
    local local_zshrc_path="${home_dir}/.zshrc"
    if [ -f "${local_zshrc_path}" ] && ! diff "${local_zshrc_path}" ./terminal-tools/zsh/.zshrc >/dev/null 2>&1; then
        cp "${local_zshrc_path}" "${local_zshrc_path}.$(date '+%Y%m%d-%H%M%S').bk"
    fi
    cp -f ./terminal-tools/zsh/.zshrc "${home_dir}"
}

setup_vim() {
    echo_blue "Setup vim..."

    deploy_vim_config
}

# shared with os-termux/setup.sh
deploy_vim_config() {
    local vimrc_path="${home_dir}/.vimrc"

    if [ ! -d "${home_dir}/.vim" ]; then
        # make and copy all things inside .vim
        cp -r ./terminal-tools/vim/.vim "${home_dir}"
    fi
    if [ -f "${vimrc_path}" ] && ! diff "${vimrc_path}" ./terminal-tools/vim/.vimrc >/dev/null 2>&1; then
        cp "${vimrc_path}" "${vimrc_path}.$(date '+%Y%m%d-%H%M%S').bk"
    fi
    cp -f ./terminal-tools/vim/.vimrc "${home_dir}"

    # TIPS: installing vim plugins takes time in CI so skip there
    if [ "${is_ci}" = "true" ]; then
        return
    fi
    # plugins.vim depends on vim-plug
    local plug_path="${home_dir}/.vim/autoload/plug.vim"
    if [ ! -f "${plug_path}" ]; then
        log "$LOG_LEVEL_INFO" "[ ] vim-plug not installed. Installing..."
        curl -fLo "${plug_path}" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    # TIPS: vim exits non-zero in headless mode because some plugin settings may error there,
    # so check the result by the plugin directory instead of the exit code
    vim -es -u "${home_dir}/.vimrc" -i NONE -c 'PlugInstall --sync' -c 'qa' || true
    if [ -d "${home_dir}/.vim/plugged" ]; then
        log "$LOG_LEVEL_INFO" "[✓] vim plugins install finished"
    else
        log "$LOG_LEVEL_WARN" "failed to install vim plugins. run ':PlugInstall' in vim"
    fi
}

### install

startup "$@" # parse arguments given to this script

case "${os}" in
"macos") homebrew_bin_path="/opt/homebrew/bin" ;;
"ubuntu") homebrew_bin_path="/home/linuxbrew/.linuxbrew/bin" ;;
esac

if [ "${flg_check_drift}" = "true" ]; then
    if [ "${os}" = "termux" ]; then
        # termux installs its own small set of tools with pkg (os-termux/setup.sh), which packages.yaml does not cover
        log "$LOG_LEVEL_WARN" "skip drift check because it is not supported on termux"
        exit 0
    fi
    load_packages
    drift_status=0
    check_drift || drift_status=$?
    # exit status is a bitmask: 1 missing packages, 2 extra packages, 4 config drift
    exit "${drift_status}"
fi

case "${os}" in
"macos" | "ubuntu")
    if [ "${os}" = "macos" ]; then
        macos_check_developer_tool
        macos_setup_defaults
    fi
    setup_package_manager
    # yq reads packages.yaml, so install it before the other packages
    brew_install yq
    load_packages
    if ! check_drift; then
        log "$LOG_LEVEL_WARN" "drift detected. missing packages are installed below, extra packages are left as they are"
    fi

    if [ "${os}" = "macos" ]; then
        setup_basic_tools macos_setup_basic_tools
        setup_personal_machine_tools
    else
        setup_basic_tools linux_setup_basic_tools
        setup_personal_machine_tools linux_setup_personal_machine_tools
    fi
    setup_zsh
    setup_vim
    ;;
"termux")
    termux_setup
    ;;
esac

echo_green "setup finished successfully!"
log "$LOG_LEVEL_INFO" "done"
