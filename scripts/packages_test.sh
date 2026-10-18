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

testdata_manifest="./scripts/testdata/packages.txt"
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

assert_equal "If macos without personal mode given, it should select common and macos packages" \
    "brew:git brew:watch go:gopls " \
    "$(selected_names "${testdata_manifest}" macos false false)"

assert_equal "If macos in personal mode given, it should also select personal packages" \
    "brew:git brew:watch brew:sass/sass/sass cask:slack go:gopls " \
    "$(selected_names "${testdata_manifest}" macos true false)"

assert_equal "If CI given, it should skip packages tagged skip-ci" \
    "brew:git brew:sass/sass/sass go:gopls " \
    "$(selected_names "${testdata_manifest}" macos true true)"

assert_equal "If ubuntu in personal mode given, it should select ubuntu packages instead of macos ones" \
    "brew:git brew:xclip brew:sass/sass/sass go:gopls command:tailscale " \
    "$(selected_names "${testdata_manifest}" ubuntu true false)"

assert_equal "If a go package given, it should print its module path as src" \
    "golang.org/x/tools/gopls@latest" \
    "$(select_packages "${testdata_manifest}" macos false false | awk -F'\t' '$1 == "go" { print $3 }')"

assert_equal "If selected packages and a manager given, it should print the names of the manager" \
    "git watch" \
    "$(package_names "$(select_packages "${testdata_manifest}" macos false false)" brew | paste -sd' ' -)"

for invalid in "brew" "apt git" "brew git os=macos unknown-tag" "go gopls"; do
    manifest=$(manifest_with "${invalid}")
    status=0
    select_packages "${manifest}" macos false false >/dev/null 2>&1 || status=$?
    assert_equal "If an invalid manifest line '${invalid}' given, it should fail" "1" "${status}"
    rm -f "${manifest}"
done

status=0
select_packages ./scripts/testdata/not-found.txt macos false false >/dev/null 2>&1 || status=$?
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

assert_equal "If nothing is installed, it should print every expected package as missing" \
    $'missing\tgit\nmissing\tjq' \
    "$(compare_package_sets $'jq\ngit' '' '')"

if [ "${failures}" -gt 0 ]; then
    echo "${failures} test(s) failed"
    exit 1
fi
echo "all tests passed"
