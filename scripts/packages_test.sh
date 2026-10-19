#!/bin/bash
# Tests for scripts/packages.sh and the pure functions of scripts/drift.sh.
# usage: ./scripts/packages_test.sh (run from the repository root)

set -eu

# shellcheck source=scripts/log.sh
source ./scripts/log.sh
# shellcheck source=scripts/packages.sh
source ./scripts/packages.sh
# shellcheck source=scripts/drift.sh
source ./scripts/drift.sh

testdata_manifest="./scripts/testdata/packages.yaml"
failures=0

# assert_equal reports whether the actual value equals the expected value for the scenario.
assert_equal() {
    local scenario=$1
    local expected=$2
    local actual=$3
    if [ "${expected}" = "${actual}" ]; then
        echo "PASS ${scenario}"
        return
    fi
    echo "FAIL ${scenario}"
    echo "  expected: $(printf '%q' "${expected}")"
    echo "  actual  : $(printf '%q' "${actual}")"
    failures=$((failures + 1))
}

# selected_names prints "<manager>:<name>" of the manifest entries selected for the environment in one line.
selected_names() {
    select_packages "$@" | awk -F'\t' '{ printf "%s:%s ", $1, $2 }'
}

# manifest_with writes the given lines to a temporary manifest and prints its path.
manifest_with() {
    local manifest
    manifest=$(mktemp)
    printf '%s\n' "$@" >"${manifest}"
    echo "${manifest}"
}

assert_equal "If macos without addons given, it should select common and macos packages" \
    "brew:git brew:watch go:gopls krew:access-matrix " \
    "$(selected_names "${testdata_manifest}" macos arm64 "" false)"

assert_equal "If macos with the personal addon given, it should also select personal packages" \
    "brew:git brew:watch brew:sass/sass/sass cask:slack go:gopls krew:access-matrix " \
    "$(selected_names "${testdata_manifest}" macos arm64 personal false)"

assert_equal "If CI given, it should skip packages excluded with ci: true" \
    "brew:git brew:sass/sass/sass go:gopls krew:access-matrix " \
    "$(selected_names "${testdata_manifest}" macos arm64 personal true)"

assert_equal "If ubuntu with the personal addon given, it should select ubuntu packages instead of macos ones" \
    "brew:git brew:xclip brew:sass/sass/sass go:gopls krew:access-matrix command:tailscale " \
    "$(selected_names "${testdata_manifest}" ubuntu x86_64 personal false)"

assert_equal "If an environment matching an exclude given, it should skip the package" \
    "brew:git brew:xclip brew:sass/sass/sass go:gopls command:tailscale " \
    "$(selected_names "${testdata_manifest}" ubuntu aarch64 personal true)"

assert_equal "If a name only entry and a map entry given, it should treat both as packages" \
    "brew:git brew:xclip " \
    "$(selected_names "$(manifest_with $'brew:' '  - git' '  - name: xclip')" ubuntu x86_64 "" false)"

assert_equal "If an empty manager list given, it should select the packages of the other managers" \
    "cask:slack " \
    "$(selected_names "$(manifest_with 'brew: []' 'cask:' '  - slack')" macos arm64 "" false)"

assert_equal "If a go package given, it should print its module path" \
    "golang.org/x/tools/gopls@latest" \
    "$(select_packages "${testdata_manifest}" macos arm64 "" false | awk -F'\t' '$1 == "go" { print $3 }')"

assert_equal "If selected packages and a manager given, it should print the names of the manager" \
    "git watch" \
    "$(package_names "$(select_packages "${testdata_manifest}" macos arm64 "" false)" brew | paste -sd' ' -)"

assert_equal "If an exclude with os and arch given, it should skip only the environment matching both" \
    "krew:access-matrix " \
    "$(selected_names "$(manifest_with $'krew:' '  - name: access-matrix' '    exclude:' '      - {os: ubuntu, arch: aarch64}')" macos aarch64 "" false)"

assert_equal "If an exclude with ci given outside CI, it should select the package" \
    "brew:opentofu " \
    "$(selected_names "$(manifest_with $'brew:' '  - name: opentofu' '    exclude:' '      - {ci: true}')" ubuntu x86_64 "" false)"

assert_equal "If an environment matching any of the excludes given, it should skip the package" \
    "" \
    "$(selected_names "$(manifest_with $'brew:' '  - name: watch' '    exclude:' '      - {os: ubuntu}' '      - {ci: true}')" macos arm64 "" true)"

# expect_invalid_manifest asserts that select_packages fails for the manifest content.
expect_invalid_manifest() {
    local scenario=$1
    local content=$2
    local manifest status=0
    manifest=$(manifest_with "${content}")
    select_packages "${manifest}" macos arm64 "" false >/dev/null 2>&1 || status=$?
    assert_equal "${scenario}" "1" "${status}"
    rm -f "${manifest}"
}

expect_invalid_manifest "If an unknown manager given, it should fail" $'apt:\n  - git'
expect_invalid_manifest "If a manager value is not a list, it should fail" $'brew: git'
expect_invalid_manifest "If an entry is neither a name nor a map, it should fail" $'brew:\n  - [git]'
expect_invalid_manifest "If an entry without name given, it should fail" $'brew:\n  - os: [macos]'
expect_invalid_manifest "If an unknown key given, it should fail" $'brew:\n  - name: git\n    oss: [macos]'
expect_invalid_manifest "If os is not a list, it should fail" $'brew:\n  - name: git\n    os: macos'
expect_invalid_manifest "If an unknown os given, it should fail" $'brew:\n  - name: git\n    os: [windows]'
expect_invalid_manifest "If an exclude ci is not a boolean, it should fail" $'brew:\n  - name: git\n    exclude:\n      - {ci: no-ci}'
expect_invalid_manifest "If an exclude has an unknown key, it should fail" $'brew:\n  - name: git\n    exclude:\n      - {personal: true}'
expect_invalid_manifest "If an exclude os is unknown, it should fail" $'brew:\n  - name: git\n    exclude:\n      - {os: windows}'
expect_invalid_manifest "If an unknown addon given, it should fail" $'brew:\n  - name: git\n    addons: [work]'
expect_invalid_manifest "If addons is not a list, it should fail" $'brew:\n  - name: git\n    addons: personal'
expect_invalid_manifest "If the removed personal key given, it should fail" $'brew:\n  - name: git\n    personal: true'
expect_invalid_manifest "If a go package without module given, it should fail" $'go:\n  - gopls'
expect_invalid_manifest "If module is given to a non go package, it should fail" $'brew:\n  - name: git\n    module: example.com/git'
expect_invalid_manifest "If exclude is not a list, it should fail" $'krew:\n  - name: ctx\n    exclude: {os: ubuntu}'
expect_invalid_manifest "If a broken YAML given, it should fail" $'brew: [git'

status=0
select_packages ./scripts/testdata/not-found.yaml macos arm64 "" false >/dev/null 2>&1 || status=$?
assert_equal "If a manifest that does not exist given, it should fail" "1" "${status}"

assert_equal "If installed packages match expected ones, it should print nothing" \
    "" \
    "$(compare_package_sets $'git\njq' $'git\njq' $'git\njq')"

assert_equal "If an expected package is not installed, it should print it as missing" \
    $'missing\tjq' \
    "$(compare_package_sets $'git\njq' 'git' 'git')"

assert_equal "If a package installed on request is not expected, it should print it as extra" \
    $'extra\ttmux' \
    "$(compare_package_sets 'git' $'git\ntmux' $'git\ntmux')"

assert_equal "If a package is installed only as a dependency, it should not print it as extra" \
    "" \
    "$(compare_package_sets 'git' $'git\nopenssl@3' 'git')"

assert_equal "If an expected package is installed only as a dependency, it should not print it as missing" \
    "" \
    "$(compare_package_sets $'git\ngo' $'git\ngo' 'git')"

assert_equal "If a tap-qualified package given, it should compare it by its last path element" \
    "" \
    "$(compare_package_sets 'microsoft/apm/apm' 'apm' 'apm')"

assert_equal "If a different version of an expected package is installed, it should not print drift" \
    "" \
    "$(compare_package_sets $'git\nnode@24' $'git\nnode@22' $'git\nnode@22')"

assert_equal "If an unversioned package is installed for a versioned expected one, it should not print drift" \
    "" \
    "$(compare_package_sets 'openssl@3' 'openssl' 'openssl')"

assert_equal "If an unexpected versioned package given, it should print it as extra without the version" \
    $'extra\tpython' \
    "$(compare_package_sets 'git' $'git\npython@3.11' $'git\npython@3.11')"

assert_equal "If an npm scoped package given, it should keep its leading @" \
    $'extra\t@scope/tool' \
    "$(compare_package_sets 'pnpm' $'pnpm\n@scope/tool' $'pnpm\n@scope/tool')"

assert_equal "If nothing is installed, it should print every expected package as missing" \
    $'missing\tgit\nmissing\tjq' \
    "$(compare_package_sets $'jq\ngit' '' '')"

if [ "${failures}" -gt 0 ]; then
    echo "${failures} test(s) failed"
    exit 1
fi
echo "all tests passed"
