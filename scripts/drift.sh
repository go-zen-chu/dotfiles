#!/bin/bash

# requires scripts/log.sh and scripts/packages.sh to be sourced (install.sh sources them)
set -eu

DRIFT_MISSING=1
DRIFT_EXTRA=2
DRIFT_CONFIG=4

# to_name_set prints the given newline separated names sorted, unique and without empty lines.
to_name_set() {
    printf '%s\n' "$1" | sed '/^$/d' | LC_ALL=C sort -u
}

# compare_package_sets prints "missing<TAB>name" for each expected package that is not installed
# and "extra<TAB>name" for each package installed on request that is not expected.
# Packages installed as dependencies are never reported as extra.
# usage: compare_package_sets <expected names> <all installed names> <names installed on request>
compare_package_sets() {
    local expected installed requested
    # tap-qualified formulae (e.g. sass/sass/sass) are listed by their last path element
    expected=$(to_name_set "$(printf '%s\n' "$1" | sed 's#.*/##')")
    installed=$(to_name_set "$2")
    requested=$(to_name_set "$3")

    LC_ALL=C comm -23 <(printf '%s\n' "${expected}") <(printf '%s\n' "${installed}") |
        awk 'NF { print "missing\t" $0 }'
    LC_ALL=C comm -13 <(printf '%s\n' "${expected}") <(printf '%s\n' "${requested}") |
        awk 'NF { print "extra\t" $0 }'
}

# package_manager_command prints the command that lists the packages of the given manager.
package_manager_command() {
    case "$1" in
    brew | cask) echo "brew" ;;
    go) echo "go" ;;
    npm) echo "npm" ;;
    krew) echo "kubectl-krew" ;;
    *) echo "" ;;
    esac
}

# list_installed_packages prints the packages installed by the given manager.
# With "requested", it prints only the packages that were installed explicitly (not as dependencies).
# `command` entries are not managed by a package manager, so the expected names are needed to probe them.
# usage: list_installed_packages <manager> <all|requested> [expected names]
list_installed_packages() {
    local manager=$1
    local scope=$2
    local expected=${3-}

    local list_command
    list_command=$(package_manager_command "${manager}")
    if [ -n "${list_command}" ] && ! hash "${list_command}" 2>/dev/null; then
        return 0
    fi

    case "${manager}" in
    brew)
        if [ "${scope}" = "requested" ]; then
            brew list --formula --installed-on-request
        else
            brew list --formula
        fi
        ;;
    cask) brew list --cask ;;
    go)
        local go_bin
        go_bin=$(go env GOBIN)
        if [ -z "${go_bin}" ]; then
            go_bin="$(go env GOPATH)/bin"
        fi
        if [ -d "${go_bin}" ]; then
            find "${go_bin}" -mindepth 1 -maxdepth 1 \( -type f -o -type l \) -exec basename {} \;
        fi
        ;;
    npm)
        local npm_root
        npm_root=$(npm root -g --no-update-notifier)
        # npm and corepack are bundled with node
        npm ls -g --depth=0 --parseable --no-update-notifier | sed -n "s#^${npm_root}/##p" | grep -vxE 'npm|corepack' || true
        ;;
    krew) kubectl krew list 2>/dev/null | grep -vx 'krew' || true ;;
    command)
        if [ "${scope}" = "requested" ]; then
            return 0
        fi
        local name
        while IFS= read -r name; do
            if [ -n "${name}" ] && hash "${name}" 2>/dev/null; then
                echo "${name}"
            fi
        done <<<"${expected}"
        ;;
    esac
}

# report_package_drift prints the missing and extra packages of each manager.
# It returns a bitmask of DRIFT_MISSING and DRIFT_EXTRA (0 when no drift).
# usage: report_package_drift <selected packages (output of select_packages)>
report_package_drift() {
    local selected=$1
    local status=0
    local manager expected list_command diff missing extra

    echo_blue "Checking package drift..."
    for manager in brew cask go npm krew command; do
        expected=$(package_names "${selected}" "${manager}")
        list_command=$(package_manager_command "${manager}")
        if [ -n "${list_command}" ] && ! hash "${list_command}" 2>/dev/null; then
            if [ -n "${expected}" ]; then
                echo_red "  [✗] ${manager}: ${list_command} not found, all packages are missing"
                echo "      missing: $(to_name_set "${expected}" | tr '\n' ' ')"
                status=$((status | DRIFT_MISSING))
            fi
            continue
        fi

        diff=$(compare_package_sets "${expected}" \
            "$(list_installed_packages "${manager}" all "${expected}")" \
            "$(list_installed_packages "${manager}" requested "${expected}")")
        missing=$(printf '%s\n' "${diff}" | awk -F'\t' '$1 == "missing" { printf "%s ", $2 }')
        extra=$(printf '%s\n' "${diff}" | awk -F'\t' '$1 == "extra" { printf "%s ", $2 }')

        if [ -z "${missing}" ] && [ -z "${extra}" ]; then
            if [ -n "${expected}" ]; then
                echo_green "  [✓] ${manager}: no drift"
            fi
            continue
        fi
        echo_red "  [✗] ${manager}:"
        if [ -n "${missing}" ]; then
            echo "      missing (not installed)       : ${missing}"
            status=$((status | DRIFT_MISSING))
        fi
        if [ -n "${extra}" ]; then
            echo "      extra (not in packages.txt)   : ${extra}"
            status=$((status | DRIFT_EXTRA))
        fi
    done
    return "${status}"
}

# current_login_shell prints the login shell of the current user.
current_login_shell() {
    local user
    user=$(whoami)
    if [ "$(uname -s)" = "Darwin" ]; then
        dscl . -read "/Users/${user}" UserShell | awk '{ print $2 }'
    else
        getent passwd "${user}" | cut -d: -f7
    fi
}

# report_check runs the given check command, prints its result and returns non-zero when it failed.
# usage: report_check <message> <command> [args...]
report_check() {
    local message=$1
    shift
    if "$@"; then
        echo_green "  [✓] ${message}"
        return 0
    fi
    echo_red "  [✗] ${message}"
    return 1
}

# git_global_config_has reports whether the global git config has the value for the key.
# usage: git_global_config_has <key> <value>
git_global_config_has() {
    git config --global --get-all "$1" 2>/dev/null | grep -qxF "$2"
}

# report_dotfiles_repo_drift checks that the dotfiles repository read by zsh and git is
# on master, has no local changes and is not behind origin/master (as of the last fetch).
# usage: report_dotfiles_repo_drift <dotfiles dir>
report_dotfiles_repo_drift() {
    local dotfiles_dir=$1

    if [ ! -d "${dotfiles_dir}" ]; then
        report_check "${dotfiles_dir} exists" false
        return 1
    fi
    # devcontainer image copies the repository without .git
    if ! git -C "${dotfiles_dir}" rev-parse --git-dir >/dev/null 2>&1; then
        echo "  [-] ${dotfiles_dir} is not a git repository, skip checking its freshness"
        return 0
    fi

    local status=0 branch changes behind=0
    branch=$(git -C "${dotfiles_dir}" symbolic-ref --short -q HEAD || echo "(detached)")
    report_check "${dotfiles_dir} is on master (current: ${branch})" \
        [ "${branch}" = "master" ] || status=1

    changes=$(git -C "${dotfiles_dir}" status --porcelain --untracked-files=no)
    report_check "${dotfiles_dir} has no uncommitted changes" \
        [ -z "${changes}" ] || status=1

    if git -C "${dotfiles_dir}" rev-parse --verify -q origin/master >/dev/null; then
        behind=$(git -C "${dotfiles_dir}" rev-list --count HEAD..origin/master)
    fi
    report_check "${dotfiles_dir} is up to date with origin/master as of the last fetch (behind: ${behind})" \
        [ "${behind}" -eq 0 ] || status=1
    return "${status}"
}

# report_config_drift checks the entry points that wire the dotfiles repository into the environment.
# It returns DRIFT_CONFIG when any check failed.
# usage: report_config_drift <dotfiles dir> <installed .zshrc> <repo .zshrc> <expected login shell> <git hooks dir>
report_config_drift() {
    local dotfiles_dir=$1
    local zshrc_path=$2
    local repo_zshrc_path=$3
    local zsh_path=$4
    local hooks_dir=$5
    local status=0

    echo_blue "Checking config drift..."
    report_dotfiles_repo_drift "${dotfiles_dir}" || status=${DRIFT_CONFIG}

    report_check "${zshrc_path} matches ${repo_zshrc_path}" \
        cmp -s "${zshrc_path}" "${repo_zshrc_path}" || status=${DRIFT_CONFIG}

    local login_shell
    login_shell=$(current_login_shell)
    report_check "login shell is ${zsh_path} (current: ${login_shell})" \
        [ "${login_shell}" = "${zsh_path}" ] || status=${DRIFT_CONFIG}

    local repo_gitconfig="${dotfiles_dir}/terminal-tools/git/.gitconfig"
    report_check "git include.path contains ${repo_gitconfig}" \
        git_global_config_has include.path "${repo_gitconfig}" || status=${DRIFT_CONFIG}

    local global_ignore="${dotfiles_dir}/terminal-tools/git/global-ignore"
    report_check "git core.excludesfile is ${global_ignore}" \
        git_global_config_has core.excludesfile "${global_ignore}" || status=${DRIFT_CONFIG}

    report_check "git core.hooksPath is ${hooks_dir}" \
        git_global_config_has core.hooksPath "${hooks_dir}" || status=${DRIFT_CONFIG}
    return "${status}"
}
