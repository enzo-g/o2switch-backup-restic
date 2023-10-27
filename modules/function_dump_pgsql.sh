dump_postgresql_dbs() {
  local FILE="$1"
  local NUM_DBS=0

  echo "Search if specific PostGreSQL DB has been listed for backup:"

  # Backup databases not related to WordPress installation
  if [ -f "$FILE" ] && [ -s "$FILE" ]; then
    NUM_DBS=$(grep -v "^#" "$FILE" | wc -l)
    echo "$NUM_DBS DB to backup based on $FILE"

    while read -r LINE; do
      if [[ "$LINE" == \#* ]]; then
        # Skip commented lines
        continue
      fi

      DB_NAME=$(echo "$LINE" | cut -d ";" -f 1)
      DB_USER=$(echo "$LINE" | cut -d ";" -f 2)
      DB_PASSWORD=$(echo "$LINE" | cut -d ";" -f 3)

      DATE=$(date +"%Y-%m-%d")
      TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
      DUMP_FILE="${DB_NAME}_${DATE}_${TIMESTAMP}.sql"
      if PGPASSWORD="$DB_PASSWORD" pg_dump --username="$DB_USER" --file="$DIR_DB_BACKUP/$DUMP_FILE" --format=custom "$DB_NAME"; then
        echo "[✓] Dump succeed for: $DB_NAME"
        gzip "$DIR_DB_BACKUP/$DUMP_FILE"
      else
        echo "[X] Dump failed for: $DB_NAME"
      fi
    done < "$FILE"
  else
    echo "[✓] No other PostGreSQL DB dump required based on: $FILE"
  fi
}