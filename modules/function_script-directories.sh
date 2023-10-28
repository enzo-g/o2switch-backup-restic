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
  SCRIPT_DIR=$(dirname $(realpath "$0"))
  # Ensure the destination parent directory exists
  mkdir -p "$(dirname $DIR_SCRIPT_BACKUP)"
  # Move the script directory to the backup directory
  mv "$SCRIPT_DIR" "$DIR_SCRIPT_BACKUP"
  # Display a message to the user
  echo "The script and its associated directories have been moved to $DIR_SCRIPT_BACKUP."
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