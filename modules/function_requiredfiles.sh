function check_required_files() {
  local paths=("$@")
  local error=0
  for path in "${paths[@]}"; do
    if [ -e "$path" ]; then
      if [ -d "$path" ]; then
        echo "[✓] Directory found: $path "
      else
        echo "[✓] File found: $path "
      fi
    else
      if [ -d "$path" ]; then
        echo "[X] Directory not found: $path"
      else
        echo "[X] File not found: $path"
      fi
      error=1
    fi
  done
  if [ $error -eq 1 ]; then
    exit 1
  fi
}