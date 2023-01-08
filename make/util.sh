#!/usr/bin/env bash
set -u

# check os
function check_os() {
	os=$(uname -s)
	case "${os}" in
	"Darwin")
		os="MacOS"
		;;
	"Linux")
		if [[ -f /etc/arch-release ]]; then
			os="ArchLinux"
		else
			echo "not supported linux" >&2
			exit 1
		fi
		;;
	*)
		echo "not supported os" >&2
		exit 1
		;;
	esac
	echo "${os}"
}

function check_cpu_arch() {
	cpu_arch=$(uname -m)
	echo "${cpu_arch}"
}

function echo_red() {
	msg=$1
	echo "$(tput setaf 1)${msg}$(tput sgr 0)"
}

function echo_green() {
	msg=$1
	echo "$(tput setaf 2)${msg}$(tput sgr 0)"
}

function echo_yellow() {
	msg=$1
	echo "$(tput setaf 3)${msg}$(tput sgr 0)"
}
