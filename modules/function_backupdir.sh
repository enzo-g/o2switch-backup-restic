# Function to check if script is located in the backup directory
function is_script_in_backup_dir() {
  # Check if the script is located in the backup directory "$DIR_SCRIPT_BACKUP"
  if [ "$(dirname "$(realpath "$0")")" = "$DIR_SCRIPT_BACKUP" ]; then
    is_script_in_backup_dir=true
  else
    is_script_in_backup_dir=false
  fi
}

function copy_script_to_backup_dir() {
  # Get the current location of the script
  SCRIPT_LOCATION=$(realpath "$0")
  # Copy the script to the backup directory
    cp "$SCRIPT_LOCATION" "$DIR_SCRIPT_BACKUP/"
  chmod +x "$DIR_SCRIPT_BACKUP/backup.sh"
}

function create_mandatory_dir() {
  dir_path="$1"
  notify="$2"

  if [ ! -d "$dir_path" ]; then
    echo "Creating directory: $dir_path"
    mkdir -p "$dir_path"
  else
    if [ "$notify" == "check" ] && [ "$(ls -A "$dir_path")" ]; then
      echo "Warning: Directory $dir_path already exists and is not empty."
    fi
  fi
}