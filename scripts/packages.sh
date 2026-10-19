#!/bin/bash

set -eu

# require_yq fails unless yq of mikefarah/yq (not the python yq of apt) is available.
require_yq() {
    if ! hash yq 2>/dev/null || ! yq --version 2>/dev/null | grep -q "mikefarah"; then
        echo "yq (https://github.com/mikefarah/yq) is required to read the package manifest" >&2
        return 1
    fi
}

# PACKAGE_ADDONS lists the optional package sets that an entry can require with `addons`.
PACKAGE_ADDONS="personal"

# SELECT_PACKAGES_AWK validates the manifest flattened by `yq -o=props` ("brew.1.os.0 = macos")
# and prints the packages that apply to the environment as tab separated "<manager> <name> <module>" lines.
# TIPS: yq expressions (select / if / tostring) behave differently between yq versions,
# so yq only flattens the manifest and the structure is checked here.
# shellcheck disable=SC2016 # $1, $2 ... are awk fields, not shell ones
SELECT_PACKAGES_AWK='
function fail(id, message) {
    printf "%s: %s: %s\n", manifest, id, message > "/dev/stderr"
    failed = 1
}
function is_index(value) { return value ~ /^[0-9]+$/ }
function in_list(list, value) { return index("," list ",", "," value ",") > 0 }
function is_valid_condition(key, value) {
    if (key == "os") { return in_list("macos,ubuntu", value) }
    if (key == "ci") { return in_list("true,false", value) }
    return value != ""
}
{
    separator = index($0, " = ")
    if (separator == 0) { fail($0, "unexpected line"); next }
    key = substr($0, 1, separator - 1)
    value = substr($0, separator + 3)
    depth = split(key, path, ".")
    manager = path[1]
    if (!in_list("brew,cask,go,npm,krew,command", manager)) { fail(manager, "unknown manager"); next }
    if (depth == 1 || !is_index(path[2])) { fail(manager, "manager value must be a list"); next }

    id = manager "." path[2]
    if (!(id in seen)) { seen[id] = 1; order[++count] = id; managers[id] = manager }
    if (depth == 2) { names[id] = value; next }

    field = path[3]
    if (in_list("name,description,module", field)) {
        if (depth != 3) { fail(id, field " must be a value"); next }
        fields[id, field] = value
    } else if (field == "os") {
        if (depth != 4 || !is_index(path[4])) { fail(id, "os must be a list"); next }
        if (!in_list("macos,ubuntu", value)) { fail(id, "unknown os: " value) }
        oses[id] = oses[id] "," value
    } else if (field == "addons") {
        if (depth != 4 || !is_index(path[4])) { fail(id, "addons must be a list"); next }
        if (!in_list(known_addons, value)) { fail(id, "unknown addon: " value) }
        required_addons[id] = required_addons[id] "," value
    } else if (field == "exclude") {
        if (depth != 5 || !is_index(path[4]) || !in_list("os,arch,ci", path[5])) {
            fail(id, "exclude must be a list of {os, arch, ci}"); next
        }
        if (!is_valid_condition(path[5], value)) { fail(id, "invalid exclude " path[5] ": " value) }
        excludes[id, path[4], path[5]] = value
        exclude_indexes[id] = exclude_indexes[id] "," path[4]
    } else {
        fail(id, "unknown key: " field)
    }
}
END {
    environment["os"] = os
    environment["arch"] = arch
    environment["ci"] = ci
    for (i = 1; i <= count; i++) {
        id = order[i]
        manager = managers[id]
        name = (id SUBSEP "name") in fields ? fields[id, "name"] : names[id]
        if (name == "") { fail(id, "name is missing"); continue }
        module = fields[id, "module"]
        if (manager == "go" && module == "") { fail(manager "." name, "go package requires module"); continue }
        if (manager != "go" && module != "") { fail(manager "." name, "module is only for go packages"); continue }

        if (oses[id] != "" && !in_list(substr(oses[id], 2), os)) { continue }
        missing_addon = 0
        split(substr(required_addons[id], 2), addon_names, ",")
        for (j in addon_names) {
            if (!in_list(addons, addon_names[j])) { missing_addon = 1 }
        }
        if (missing_addon) { continue }
        excluded = 0
        split(substr(exclude_indexes[id], 2), indexes, ",")
        for (j in indexes) {
            matched = 1
            for (condition in environment) {
                expected = excludes[id, indexes[j], condition]
                if (expected != "" && expected != environment[condition]) { matched = 0 }
            }
            if (matched) { excluded = 1 }
        }
        if (excluded) { continue }
        if (!failed) { printf "%s\t%s\t%s\n", manager, name, module }
    }
    exit failed
}'

# select_packages prints the entries of the package manifest that apply to the given environment
# as tab separated "<manager> <name> <module>" lines. It fails on a malformed manifest.
# usage: select_packages <manifest path> <os> <arch> <enabled addons (comma separated, e.g. personal)> <ci (true|false)>
select_packages() {
    local manifest=$1
    local os=$2
    local arch=$3
    local addons=$4
    local ci=$5

    if [ ! -f "${manifest}" ]; then
        echo "package manifest not found: ${manifest}" >&2
        return 1
    fi
    require_yq

    local props
    if ! props=$(yq -o=props '... comments=""' "${manifest}"); then
        echo "${manifest}: failed to parse" >&2
        return 1
    fi
    printf '%s\n' "${props}" | sed '/^$/d' | awk -v manifest="${manifest}" -v os="${os}" -v arch="${arch}" \
        -v addons="${addons}" -v ci="${ci}" \
        -v known_addons="${PACKAGE_ADDONS}" "${SELECT_PACKAGES_AWK}"
}

# package_names prints the names of the selected packages managed by the given manager.
# usage: package_names <selected packages (output of select_packages)> <manager>
package_names() {
    printf '%s\n' "$1" | awk -F'\t' -v manager="$2" '$1 == manager { print $2 }'
}
