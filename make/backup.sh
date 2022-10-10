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

mkdir ${backup_dir_path}
cp -R ~/.ssh ${backup_dir_path}
cp -R ~/.gnupg ${backup_dir_path}
cp -R ~/.config ${backup_dir_path}
cp ~/local.zsh ${backup_dir_path}
cp ~/.zsh_history ${backup_dir_path}

