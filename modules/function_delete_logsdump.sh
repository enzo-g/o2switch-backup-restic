function delete_old_logs() {
  local dir_to_clean="$1"
  local days_to_keep="$2"
  local count=$(find "$dir_to_clean" -type f -name "*.txt" -mtime +$days_to_keep | wc -l)
  if [ $count -gt 0 ]; then
    echo "Deleting log files that are $days_to_keep days old or older from $dir_to_clean."
    find "$dir_to_clean" -type f -name "*.txt" -mtime +$days_to_keep -delete
  fi
}

function delete_old_dumps() {
  local dir_to_clean="$1"
  local days_to_keep="$2"
  local count=$(find "$dir_to_clean" -name "*.sql.gz" -type f -mtime +$days_to_keep | wc -l)
  if [ $count -gt 0 ]; then
    echo "Deleting database dump files that are $days_to_keep days old or older from $dir_to_clean."
    find "$dir_to_clean" -name "*.sql.gz" -type f -mtime +$days_to_keep -exec rm {} \;
  fi
}