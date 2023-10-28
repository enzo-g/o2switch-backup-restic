function check_script_location() {
  local expected_dir="$1"
  # The directory of the parent script (backup.sh) will be in the calling context's $0
  if [ "$(dirname "$(realpath "${BASH_SOURCE[1]}")")" = "$expected_dir" ]; then
    echo true
  else
    echo false
  fi
}

# Usage:
# if [ "$(check_script_location "$DIR_INSTALLATION")" = "true" ]; then
#   echo "Backup script is in the expected directory"
# else
#   echo "Backup script is NOT in the expected directory"
# fi
