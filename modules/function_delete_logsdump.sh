function delete_old_logs() {
  COUNT0=$(find "$DIR_SCRIPT_LOGS" -type f -name "*.txt" -mtime +$LOG_DAYS_TO_KEEP | wc -l)
  if [ $COUNT0 -gt 0 ]; then
    echo "Deleting log files that are $LOG_DAYS_TO_KEEP days old or older."
    find "$DIR_SCRIPT_LOGS" -type f -name "*.txt" -mtime +$LOG_DAYS_TO_KEEP -delete
  fi
}

function delete_old_dumps() {
  # Count the number of files to be deleted
  COUNT=$(find "$DIR_DB_BACKUP" -name "*.sql.gz" -type f -mtime +$DUMP_DAYS | wc -l)
  # Output the echo message only if there are files to be deleted
  if [ $COUNT -gt 0 ]; then
    echo "Deleting database dump files that are $DUMP_DAYS days old or older."
    find "$DIR_DB_BACKUP" -name "*.sql.gz" -type f -mtime +$DUMP_DAYS -exec rm {} \;
  fi
}