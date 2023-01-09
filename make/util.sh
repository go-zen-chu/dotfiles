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

function echo_color() {
	msg=$1
	color=$2
	# in CI environment, TERM env var might not set
	if [ ! -z $CI ] && [ -z $TERM ]; then
		echo "[INFO] CI=${CI} and TERM=${TERM} is empty. Set TERM to xterm-color"
		export TERM=xterm-color
	fi
	case "${color}" in
	"red")
		echo "$(tput bold)$(tput setaf 1)${msg}$(tput sgr 0)"
		;;
	"green")
		echo "$(tput setaf 2)${msg}$(tput sgr 0)"
		;;
	"yellow")
		echo "$(tput bold)$(tput setaf 3)${msg}$(tput sgr 0)"
		;;
	*)
		echo "[util.sh error: unsupported color]${msg}"
		;;
	esac
}

function echo_red() {
	echo_color "$1" "red"
}

function echo_green() {
	echo_color "$1" "green"
}

function echo_yellow() {
	echo_color "$1" "yellow"
}
