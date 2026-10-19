#!/bin/bash

set -eu

# flattens each entry of the manifest into "|" separated fields:
# manager|name|os|personal|ci|module|exclude (os:arch,...)|keys|invalid tag
# keys are taken before reading the other fields since yq adds the keys it reads to the map.
# TIPS: `select(tag != ...)` and `//` misjudge empty lists and other types in yq, so branch with if / else.
# shellcheck disable=SC2016 # $manager / $keys are yq variables, not shell ones
PACKAGE_MANIFEST_QUERY='to_entries[] | .key as $manager |
  (if (.value | tag) == "!!seq" then .value[] else {"invalid": "manager value must be a list"} end) |
  (if tag == "!!str" then {"name": .} elif tag == "!!map" then . else {"invalid": "entry must be a name or a map"} end) |
  (keys | join(",")) as $keys |
  [
    $manager,
    (.name | tostring),
    ((.os | select(tag == "!!seq") | "list:" + join(",")) // (.os | tostring)),
    (.personal | tostring),
    (.ci | tostring),
    (.module | tostring),
    ((.exclude | select(tag == "!!seq") | "list:" + (map((.os | tostring) + ":" + (.arch | tostring)) | join(","))) // (.exclude | tostring)),
    $keys,
    (.invalid | tostring)
  ] | join("|")'

# require_yq fails unless yq of mikefarah/yq (not the python yq of apt) is available.
require_yq() {
    if ! hash yq 2>/dev/null || ! yq --version 2>/dev/null | grep -q "mikefarah"; then
        echo "yq (https://github.com/mikefarah/yq) is required to read the package manifest" >&2
        return 1
    fi
}

# list_contains reports whether the comma separated list has the value.
list_contains() {
    case ",$1," in
    *",$2,"*) return 0 ;;
    *) return 1 ;;
    esac
}

# matches_any_exclude reports whether the environment matches any "os:arch" pattern
# of the comma separated list ("null" matches any value).
matches_any_exclude() {
    local excludes=$1
    local os=$2
    local arch=$3
    local pattern exclude_os exclude_arch
    local -a patterns
    IFS=',' read -r -a patterns <<<"${excludes}"
    for pattern in "${patterns[@]+"${patterns[@]}"}"; do
        exclude_os=${pattern%%:*}
        exclude_arch=${pattern#*:}
        if { [ "${exclude_os}" = "null" ] || [ "${exclude_os}" = "${os}" ]; } &&
            { [ "${exclude_arch}" = "null" ] || [ "${exclude_arch}" = "${arch}" ]; }; then
            return 0
        fi
    done
    return 1
}

# select_packages prints the entries of the package manifest that apply to the given environment
# as tab separated "<manager> <name> <module>" lines. It fails on a malformed manifest.
# usage: select_packages <manifest path> <os> <arch> <personal mode (true|false)> <ci (true|false)>
select_packages() {
    local manifest=$1
    local os=$2
    local arch=$3
    local personal=$4
    local ci=$5

    if [ ! -f "${manifest}" ]; then
        echo "package manifest not found: ${manifest}" >&2
        return 1
    fi
    require_yq

    local entries
    if ! entries=$(yq -r "${PACKAGE_MANIFEST_QUERY}" "${manifest}"); then
        echo "${manifest}: failed to parse" >&2
        return 1
    fi

    local manager name os_list entry_personal entry_ci module excludes keys invalid key
    local -a entry_keys
    while IFS='|' read -r manager name os_list entry_personal entry_ci module excludes keys invalid; do
        if [ -z "${manager}" ]; then
            continue
        fi
        local where="${manifest}: ${manager}.${name}"
        if [ "${invalid}" != "null" ]; then
            echo "${manifest}: ${manager}: ${invalid}" >&2
            return 1
        fi
        case "${manager}" in
        brew | cask | go | npm | krew | command) ;;
        *)
            echo "${manifest}: unknown manager: ${manager}" >&2
            return 1
            ;;
        esac
        if [ "${name}" = "null" ] || [ -z "${name}" ]; then
            echo "${manifest}: ${manager}: name is missing" >&2
            return 1
        fi
        IFS=',' read -r -a entry_keys <<<"${keys}"
        for key in "${entry_keys[@]+"${entry_keys[@]}"}"; do
            if ! list_contains "name,description,os,personal,ci,module,exclude" "${key}"; then
                echo "${where}: unknown key: ${key}" >&2
                return 1
            fi
        done
        case "${os_list}" in
        null) os_list="" ;;
        list:*) os_list=${os_list#list:} ;;
        *)
            echo "${where}: os must be a list" >&2
            return 1
            ;;
        esac
        local listed_os
        local -a listed_oses
        IFS=',' read -r -a listed_oses <<<"${os_list}"
        for listed_os in "${listed_oses[@]+"${listed_oses[@]}"}"; do
            if ! list_contains "macos,ubuntu" "${listed_os}"; then
                echo "${where}: unknown os: ${listed_os}" >&2
                return 1
            fi
        done
        if ! list_contains "true,false,null" "${entry_personal}" || ! list_contains "true,false,null" "${entry_ci}"; then
            echo "${where}: personal / ci must be true or false" >&2
            return 1
        fi
        if [ "${manager}" = "go" ] && [ "${module}" = "null" ]; then
            echo "${where}: go package requires module" >&2
            return 1
        fi
        if [ "${manager}" != "go" ] && [ "${module}" != "null" ]; then
            echo "${where}: module is only for go packages" >&2
            return 1
        fi
        case "${excludes}" in
        null) excludes="" ;;
        list:*) excludes=${excludes#list:} ;;
        *)
            echo "${where}: exclude must be a list of {os, arch}" >&2
            return 1
            ;;
        esac

        if [ -n "${os_list}" ] && ! list_contains "${os_list}" "${os}"; then
            continue
        fi
        if [ "${entry_personal}" = "true" ] && [ "${personal}" != "true" ]; then
            continue
        fi
        if [ "${entry_ci}" = "false" ] && [ "${ci}" = "true" ]; then
            continue
        fi
        if matches_any_exclude "${excludes}" "${os}" "${arch}"; then
            continue
        fi
        if [ "${module}" = "null" ]; then
            module=""
        fi
        printf '%s\t%s\t%s\n' "${manager}" "${name}" "${module}"
    done <<<"${entries}"
}

# package_names prints the names of the selected packages managed by the given manager.
# usage: package_names <selected packages (output of select_packages)> <manager>
package_names() {
    printf '%s\n' "$1" | awk -F'\t' -v manager="$2" '$1 == manager { print $2 }'
}
