# Define function to create .htaccess file if it doesn't exist, overwrite it if the content is not correct.
function create_htaccess_file() {
  # Define the path to the .htaccess file
  HTACCESS_FILE="$1/.htaccess"
  DESIRED_CONTENT="deny from all"

  if [ -f "$HTACCESS_FILE" ]; then
    # If the file exists, check if its content matches the desired content
    if [ "$(cat "$HTACCESS_FILE")" == "$DESIRED_CONTENT" ]; then
      # If the content matches, display a message and return
      echo "[✓] Content up-to-date for: $HTACCESS_FILE"
      return
    else
      # If the content is different, display a message and overwrite the file
      echo "$DESIRED_CONTENT" > "$HTACCESS_FILE"
      echo "[!] Content updated to correct value for $HTACCESS_FILE"
      return
    fi
  else
    # If the file does not exist, create it with the desired content and display a message
    echo "[X] File missing: $HTACCESS_FILE."
    echo "$DESIRED_CONTENT" > "$HTACCESS_FILE"
    if [ -f "$HTACCESS_FILE" ]; then
      echo "[!] File created: $HTACCESS_FILE."
    else
      echo "[X] Error: Failed to create .htaccess file: $HTACCESS_FILE"
      exit 1
    fi
    return
  fi
}
