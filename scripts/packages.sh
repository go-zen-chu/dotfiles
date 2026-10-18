#!/bin/bash

set -eu

# select_packages prints the entries of the package manifest that apply to the given environment
# as tab separated "<manager> <name> <src>" lines. It fails on a malformed manifest.
# usage: select_packages <manifest path> <os> <personal mode (true|false)> <ci (true|false)>
select_packages() {
    local manifest=$1
    local os=$2
    local personal=$3
    local ci=$4

    if [ ! -f "${manifest}" ]; then
        echo "package manifest not found: ${manifest}" >&2
        return 1
    fi

    local line lineno=0 manager name src applies tag
    local -a fields
    while IFS= read -r line || [ -n "${line}" ]; do
        lineno=$((lineno + 1))
        line=${line%%#*}
        read -r -a fields <<<"${line}"
        if [ "${#fields[@]}" -eq 0 ]; then
            continue
        fi
        if [ "${#fields[@]}" -lt 2 ]; then
            echo "${manifest}:${lineno}: package name is missing" >&2
            return 1
        fi

        manager=${fields[0]}
        name=${fields[1]}
        src=""
        applies="true"
        case "${manager}" in
        brew | cask | go | npm | krew | command) ;;
        *)
            echo "${manifest}:${lineno}: unknown manager: ${manager}" >&2
            return 1
            ;;
        esac

        for tag in "${fields[@]:2}"; do
            case "${tag}" in
            os=*)
                if [ "${tag#os=}" != "${os}" ]; then
                    applies="false"
                fi
                ;;
            personal)
                if [ "${personal}" != "true" ]; then
                    applies="false"
                fi
                ;;
            skip-ci)
                if [ "${ci}" = "true" ]; then
                    applies="false"
                fi
                ;;
            src=*) src=${tag#src=} ;;
            *)
                echo "${manifest}:${lineno}: unknown tag: ${tag}" >&2
                return 1
                ;;
            esac
        done

        if [ "${manager}" = "go" ] && [ -z "${src}" ]; then
            echo "${manifest}:${lineno}: go package requires src=<module>" >&2
            return 1
        fi
        if [ "${applies}" = "true" ]; then
            printf '%s\t%s\t%s\n' "${manager}" "${name}" "${src}"
        fi
    done <"${manifest}"
}

# package_names prints the names of the selected packages managed by the given manager.
# usage: package_names <selected packages (output of select_packages)> <manager>
package_names() {
    printf '%s\n' "$1" | awk -F'\t' -v manager="$2" '$1 == manager { print $2 }'
}
