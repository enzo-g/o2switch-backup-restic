function create_mandatory_dir() {
  local -r DIR_PATH="$1"
  local -r NOTIFY="$2"

  if [ ! -d "$DIR_PATH" ]; then
    echo "Creating directory: $DIR_PATH"
    mkdir -p "$DIR_PATH"
  else
    if [ "$NOTIFY" == "check" ] && [ "$(ls -A "$DIR_PATH")" ]; then
      echo "Warning: Directory $DIR_PATH already exists and is not empty."
    fi
  fi
}