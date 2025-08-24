dump_mysql_dbs() {
  local -r FILE="$1"
  local NUM_DBS=0

  echo "Search if specific DB has been listed for backup:"
  # Backup databases not related to WordPress installation
  if [ -f "$FILE" ] && [ -s "$FILE" ]; then
    NUM_DBS=$(grep -v "^#" "$FILE" | wc -l)
    echo "$NUM_DBS DB to backup based on $FILE"

    while read -r LINE; do
      if [[ "$LINE" == \#* ]]; then
        # Skip commented lines
        continue
      fi
      local DB_NAME=$(echo "$LINE" | cut -d ";" -f 1)
      local DB_USER=$(echo "$LINE" | cut -d ";" -f 2)
      local DB_PASSWORD=$(echo "$LINE" | cut -d ";" -f 3)
      local DATE=$(date +"%Y-%m-%d")
      local TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
      local DUMP_FILE="${DB_NAME}_${DATE}_${TIMESTAMP}.sql"
      # Create temporary MySQL config file with credentials
      local MYSQL_CONFIG=$(mktemp)
      echo "[client]" > "$MYSQL_CONFIG"
      echo "user=$DB_USER" >> "$MYSQL_CONFIG"
      echo "password=$DB_PASSWORD" >> "$MYSQL_CONFIG"
      chmod 600 "$MYSQL_CONFIG"
      
      if mysqldump --defaults-file="$MYSQL_CONFIG" --databases "$DB_NAME" > "$DIR_DB_BACKUP/$DUMP_FILE"; then
        echo "[✓] Dump succeed for: $DB_NAME"
        gzip "$DIR_DB_BACKUP/$DUMP_FILE"
      else
        echo "[X] Dump failed for: $DB_NAME"
      fi
      
      # Clean up temporary config file
      rm -f "$MYSQL_CONFIG"
    done < "$FILE"
  else
    echo "[✓] No other DB dump required based on: $FILE"
  fi
}