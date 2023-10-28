# Define function to create .htaccess file if it doesn't exist, overwrite it if the content is not correct.
function create_htaccess_file() {
  # Desired content for the .htaccess file
  DESIRED_CONTENT="deny from all"

  # Iterate over each directory passed as argument
  for dir in "$@"; do
    # Define the path to the .htaccess file
    HTACCESS_FILE="$dir/.htaccess"

    if [ -f "$HTACCESS_FILE" ]; then
      # If the file exists, check if its content matches the desired content
      if [ "$(cat "$HTACCESS_FILE")" == "$DESIRED_CONTENT" ]; then
        # If the content matches, display a message and continue to the next directory
        echo "[✓] Content up-to-date for: $HTACCESS_FILE"
      else
        # If the content is different, display a message and overwrite the file
        echo "$DESIRED_CONTENT" > "$HTACCESS_FILE"
        echo "[!] Content updated to correct value for $HTACCESS_FILE"
      fi
    else
      # If the file does not exist, create it with the desired content and display a message
      echo "$DESIRED_CONTENT" > "$HTACCESS_FILE"
      if [ -f "$HTACCESS_FILE" ]; then
        echo "[✓] File created: $HTACCESS_FILE."
      else
        echo "[X] Error: Failed to create .htaccess file: $HTACCESS_FILE"
        exit 1
      fi
    fi
  done
}

# Example usage:
# create_htaccess_file "$DIR_ONE" "$DIR_TWO" "$DIR_THREE"