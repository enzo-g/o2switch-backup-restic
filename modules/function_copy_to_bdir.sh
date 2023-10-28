function copy_script_to_backup_dir() {
  # Get the current location of the script
  SCRIPT_DIR=$(dirname $(realpath "$0"))
  
  # Ensure the destination directory exists
  mkdir -p "$DIR_SCRIPT_BACKUP"
  
  # Copy the script directory to the backup directory
  cp -r "$SCRIPT_DIR/" "$DIR_SCRIPT_BACKUP/"
  
  # Display a message to the user
  echo "The script installation is complete. It and its associated directories have been copied to $DIR_SCRIPT_BACKUP."
  echo "To execute the backup, you should now run the script from the new location: $DIR_SCRIPT_BACKUP/backup.sh"
}