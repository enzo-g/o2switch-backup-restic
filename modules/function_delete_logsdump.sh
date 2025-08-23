function delete_old_logs() {
  local -r DIR_TO_CLEAN="$1"
  local -r DAYS_TO_KEEP="$2"
  local COUNT=$(find "$DIR_TO_CLEAN" -type f -name "*.txt" -mtime +$DAYS_TO_KEEP | wc -l)
  if [ $COUNT -gt 0 ]; then
    echo "Deleting log files that are $DAYS_TO_KEEP days old or older from $DIR_TO_CLEAN."
    find "$DIR_TO_CLEAN" -type f -name "*.txt" -mtime +$DAYS_TO_KEEP -delete
  fi
}

function delete_old_dumps() {
  local -r DIR_TO_CLEAN="$1"
  local -r DAYS_TO_KEEP="$2"
  local COUNT=$(find "$DIR_TO_CLEAN" -name "*.sql.gz" -type f -mtime +$DAYS_TO_KEEP | wc -l)
  if [ $COUNT -gt 0 ]; then
    echo "Deleting database dump files that are $DAYS_TO_KEEP days old or older from $DIR_TO_CLEAN."
    find "$DIR_TO_CLEAN" -name "*.sql.gz" -type f -mtime +$DAYS_TO_KEEP -exec rm {} \;
  fi
}