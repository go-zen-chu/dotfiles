#!/bin/bash
set -eu

source ./make/util.sh

date="$(date '+%Y%m%d-%H%M%S')"
# e.g. /Users/you/Library/CloudStorage/Cloud/Backup
bpath=$(sh -c 'read -p "Directory path for storing backup: " bpath; echo "$bpath"')
backup_dir_path="${bpath%/}/${date}"
if [[ ! -d ${bpath} ]]; then
	echo_red "not valid dir path"
	exit 1
else
	echo_green "creating backup dir to ${backup_dir_path}"
fi

mkdir "${backup_dir_path}"
# ssh
cp -R ~/.ssh "${backup_dir_path}"
if [[ -d "${HOME}/.gnupg" ]]; then
	cp -R ~/.gnupg "${backup_dir_path}"
fi
# general config files
if [[ -d "${HOME}/.config" ]]; then
	cp -R ~/.config "${backup_dir_path}"
fi
# zsh
cp ~/local.zsh "${backup_dir_path}"
cp ~/.zsh_history "${backup_dir_path}"

# atuin
if [[ -d "${HOME}/.local/share/atuin" ]]; then
	mkdir -p "${backup_dir_path}/.local/share/"
	cp -R ~/.local/share/atuin "${backup_dir_path}"
fi
