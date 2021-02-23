#!/usr/bin/env bash
set -ux

source ./make/util.sh

echo_green "[INFO] setup zsh"
os=$(check_os)
# check command exists
if ! hash zsh 2>/dev/null; then
	case "${os}" in
	"MacOS")
		brew install zsh
		# set shell as zsh
		echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
		chsh -s /usr/local/bin/zsh || true # for skipping in CI
		;;
	"CentOS")
		sudo yum install -y zsh
		;;
	"ArchLinux")
		sudo pacman -Sy --noconfirm zsh
		;;
	esac
fi

# install zinit
if [[ ! -d "${HOME}/.zinit" ]]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
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
