#!/bin/bash

set -eu

# require_yq fails unless yq of mikefarah/yq (not the python yq of apt) is available.
require_yq() {
    if ! hash yq 2>/dev/null || ! yq --version 2>/dev/null | grep -q "mikefarah"; then
        echo "yq (https://github.com/mikefarah/yq) is required to read the package manifest" >&2
        return 1
    fi
}

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
    if (in_list("name,description,personal,ci,module", field)) {
        if (depth != 3) { fail(id, field " must be a value"); next }
        fields[id, field] = value
    } else if (field == "os") {
        if (depth != 4 || !is_index(path[4])) { fail(id, "os must be a list"); next }
        if (!in_list("macos,ubuntu", value)) { fail(id, "unknown os: " value) }
        oses[id] = oses[id] "," value
    } else if (field == "exclude") {
        if (depth != 5 || !is_index(path[4]) || !in_list("os,arch", path[5])) {
            fail(id, "exclude must be a list of {os, arch}"); next
        }
        excludes[id, path[4], path[5]] = value
        exclude_indexes[id] = exclude_indexes[id] "," path[4]
    } else {
        fail(id, "unknown key: " field)
    }
}
END {
    for (i = 1; i <= count; i++) {
        id = order[i]
        manager = managers[id]
        name = (id SUBSEP "name") in fields ? fields[id, "name"] : names[id]
        if (name == "") { fail(id, "name is missing"); continue }
        id = manager "." name
        personal_only = fields[order[i], "personal"]
        ci_enabled = fields[order[i], "ci"]
        module = fields[order[i], "module"]
        if (!in_list(",true,false", personal_only) || !in_list(",true,false", ci_enabled)) {
            fail(id, "personal / ci must be true or false"); continue
        }
        if (manager == "go" && module == "") { fail(id, "go package requires module"); continue }
        if (manager != "go" && module != "") { fail(id, "module is only for go packages"); continue }

        if (oses[order[i]] != "" && !in_list(substr(oses[order[i]], 2), os)) { continue }
        if (personal_only == "true" && personal != "true") { continue }
        if (ci_enabled == "false" && ci == "true") { continue }
        excluded = 0
        split(substr(exclude_indexes[order[i]], 2), indexes, ",")
        for (j in indexes) {
            exclude_os = excludes[order[i], indexes[j], "os"]
            exclude_arch = excludes[order[i], indexes[j], "arch"]
            if ((exclude_os == "" || exclude_os == os) && (exclude_arch == "" || exclude_arch == arch)) { excluded = 1 }
        }
        if (excluded) { continue }
        if (!failed) { printf "%s\t%s\t%s\n", manager, name, module }
    }
    exit failed
}'

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

    local props
    if ! props=$(yq -o=props '... comments=""' "${manifest}"); then
        echo "${manifest}: failed to parse" >&2
        return 1
    fi
    printf '%s\n' "${props}" | sed '/^$/d' | awk -v manifest="${manifest}" -v os="${os}" -v arch="${arch}" \
        -v personal="${personal}" -v ci="${ci}" "${SELECT_PACKAGES_AWK}"
}

# package_names prints the names of the selected packages managed by the given manager.
# usage: package_names <selected packages (output of select_packages)> <manager>
package_names() {
    printf '%s\n' "$1" | awk -F'\t' -v manager="$2" '$1 == manager { print $2 }'
}
