#!/usr/bin/env bash

set -eu

release_url=$1
checksum_url=$2
binary_name=$3
cleanup=${4:-true}

function checksum() {
    release_name=$1
    checksum_name=$2
    cs="no such checksum"
    os=$(uname -s)
    case "${os}" in
    "Linux")
        if hash sha256sum 2>/dev/null; then
            cs=$(sha256sum "${release_name}")
        else
            echo "could not find sha256sum command"
            return 1
        fi
        ;;
    "Darwin")
        if hash shasum 2>/dev/null; then
            cs=$(shasum -a 256 "${release_name}")
        else
            echo "could not find shasum command"
            return 1
        fi
        ;;
    *)
        echo "unsupported os: ${os}"
        return 1
        ;;
    esac
    # returns 0 if true
    grep -q "${cs}" "${checksum_name}"
}

function download_release_checksum() {
    release_url=$1
    checksum_url=$2
    binary_name=$3
    cleanup=${4:-true}
    # process
    untar_dir=download-$(date +"%Y%m%d-%H%M%S")
    mkdir "${untar_dir}"
    release_name="${release_url##*/}"
    wget "${release_url}" -O "${release_name}"
    checksum_name="${checksum_url##*/}"
    wget "${checksum_url}" -O "${checksum_name}"
    if checksum "${release_name}" "${checksum_name}"; then
        tar -xvf "${release_name}" -C "${untar_dir}"
        cp "${untar_dir}/${binary_name}" "./${binary_name}"
    else
        echo "checksum does not matched. abort"
    fi
    if "${cleanup}"; then
        rm "${checksum_name}"
        rm "${release_name}"
        rm -r "${untar_dir}"
    fi
}

download_release_checksum "${release_url}" "${checksum_url}" "${binary_name}" ${cleanup}
