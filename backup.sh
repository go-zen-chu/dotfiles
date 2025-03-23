#!/usr/bin/env bash

source "./scripts/log.sh"

set -eu

timestamp="$(date '+%Y%m%d-%H%M%S')"
log "$LOG_LEVEL_INFO" "[backup.sh] Start backup script on ${timestamp}"

cmdname=$(basename "$0")
arg_backup_path=""

while getopts "p:" opt; do
	case $opt in
	"p") arg_backup_path="$OPTARG" ;;
	*)
		echo "Usage: ${cmdname} [-p (backup path)]" 1>&2
		exit 0
		;;
	esac
done

if [ -z "$arg_backup_path" ]; then
	log "$LOG_LEVEL_ERROR" "-p option (backup path) is required"
	exit 1
fi

backup_dir_path="${arg_backup_path%/}/${timestamp}"
log "$LOG_LEVEL_INFO" "[backup.sh] Backup destination path: ${backup_dir_path}"

if [[ ! -d "${arg_backup_path}" ]]; then
	log "$LOG_LEVEL_ERROR" "Not valid dir path: ${arg_backup_path}"
	exit 1
fi

log "$LOG_LEVEL_INFO" "[backup.sh] Create backup dir to ${backup_dir_path}"
mkdir -p "${backup_dir_path}"

# TIPS: Make important files to be backed up first because some cloud-storage may took time to upload directory
if [[ -f "${HOME}/local.zsh" ]]; then
	cp ~/local.zsh "${backup_dir_path}"
	log "$LOG_LEVEL_INFO" "[backup.sh] [✓] Backup .zshrc finished"
fi

if [[ -f "${HOME}/.zsh_history" ]]; then
	cp ~/.zsh_history "${backup_dir_path}"
	log "$LOG_LEVEL_INFO" "[backup.sh] [✓] Backup .zsh_history finished"
fi

if [[ -d "${HOME}/.ssh" ]]; then
	cp -R ~/.ssh "${backup_dir_path}"
	log "$LOG_LEVEL_INFO" "[backup.sh] [✓] Backup ssh finished"
else
	log "$LOG_LEVEL_INFO" "[backup.sh] [✓] No .ssh folder found"
fi

if [[ -d "${HOME}/.gnupg" ]]; then
	cp -R ~/.gnupg "${backup_dir_path}"
	log "$LOG_LEVEL_INFO" "[backup.sh] [✓] Backup gnupg finished"
else
	log "$LOG_LEVEL_INFO" "[backup.sh] [✓] No .gnupg folder found"
fi

if [[ -d "${HOME}/.config" ]]; then
	cp -R ~/.config "${backup_dir_path}"
	log "$LOG_LEVEL_INFO" "[backup.sh] [✓] Backup .config finished"
else
	log "$LOG_LEVEL_INFO" "[backup.sh] [✓] No .config folder found"
fi

if [[ -d "${HOME}/.local/share/atuin" ]]; then
	mkdir -p "${backup_dir_path}/.local/share/"
	cp -R ~/.local/share/atuin "${backup_dir_path}"
	log "$LOG_LEVEL_INFO" "[backup.sh] [✓] Backup atuin database finished"
else
	log "$LOG_LEVEL_INFO" "[backup.sh] [✓] No atuin database found"
fi

echo_blue "[backup.sh] $(date '+%Y%m%d-%H%M%S') Finish backup"
