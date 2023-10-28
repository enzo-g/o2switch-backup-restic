function is_script_in_backup_dir() {
  # Check if the script is located in the backup directory "$DIR_SCRIPT_BACKUP"
  if [ "$(dirname "$(realpath "$0")")" = "$DIR_SCRIPT_BACKUP" ]; then
    is_script_in_backup_dir=true
  else
    is_script_in_backup_dir=false
  fi
}