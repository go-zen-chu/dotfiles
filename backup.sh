#!/usr/bin/env bash

# shellcheck source=scripts/log.sh
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

# Credentials (~/.ssh, ~/.gnupg, tokens under ~/.config such as gh and gcloud, the atuin key and session)
# are not backed up: a copy in cloud storage would spread a leak from one device to every device.
# Configs worth keeping live in this repository, and credentials are issued again on a new device.
atuin_data_dir="${HOME}/.local/share/atuin"
if [[ -f "${atuin_data_dir}/history.db" ]]; then
	mkdir -p "${backup_dir_path}/atuin"
	for db_file in history.db history.db-wal history.db-shm; do
		if [[ -f "${atuin_data_dir}/${db_file}" ]]; then
			cp "${atuin_data_dir}/${db_file}" "${backup_dir_path}/atuin/"
		fi
	done
	log "$LOG_LEVEL_INFO" "[backup.sh] [✓] Backup atuin history finished"
else
	log "$LOG_LEVEL_INFO" "[backup.sh] [✓] No atuin history found"
fi

echo_blue "[backup.sh] $(date '+%Y%m%d-%H%M%S') Finish backup"
