#!/usr/bin/env bash
set -u

source ./make/util.sh

echo_green "[INFO] setup zsh"
os=$(check_os)
# zsh is preinstalled in MacOS, so make sure brew installed zsh is used
if [[ "${os}" == "MacOS" ]]; then
	brew install zsh
	zsh_path="/usr/local/bin/zsh"
	cpu_arch=$(check_cpu_arch)
	if [[ "${cpu_arch}" == "arm64" ]]; then
		zsh_path="/opt/homebrew/bin/zsh"
	fi
	if [[ $(grep "${zsh_path}" /etc/shells) ]]; then
		echo "${zsh_path} exists in /etc/shells"
	else
	    # set shell as zsh
	    echo "${zsh_path}" | sudo tee -a /etc/shells
	    chsh -s ${zsh_path} || true # for skipping in CI
	fi
fi

# check command exists
if ! hash zsh 2>/dev/null; then
	case "${os}" in
	"CentOS")
		sudo yum install -y zsh
		;;
	"ArchLinux")
		sudo pacman -Sy --noconfirm zsh
		;;
	esac
fi

if [[ ! -f "${HOME}/local.zsh" ]]; then
	cp -i ./zsh/local.zsh "${HOME}"
fi

if [[ -f "${HOME}/.zshrc" ]]; then
	if diff "${HOME}/.zshrc" ./zsh/.zshrc >/dev/null; then 
		echo_green ".zshrc is same as dotfiles"
	else
		# backup
		cp "${HOME}/.zshrc" "${HOME}/.zshrc.$(date '+%Y%m%d-%H%M%S').bk"
	fi
fi
cp -f ./zsh/.zshrc "${HOME}"

echo_green "[INFO] Finish setup zsh"
