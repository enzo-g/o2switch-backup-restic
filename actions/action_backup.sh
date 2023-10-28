#BACKUP
###########
# The sequence below is executed if the --backup argument is being used.

echo "Load variables from: $RESTIC_CONF"
if [ -f "$RESTIC_CONF" ]; then
  echo "[✓] Restic configuration file found: $RESTIC_CONF"
  source "$RESTIC_CONF"
else
  echo "[X] Restic configuration file not found: $RESTIC_CONF"
  echo "[!] Have you run backup.sh --install previously?"
  exit 1
fi

# Redirect all output to the log file and the terminal    
{
my_date=$(date +"%Y-%m-%d %H:%M")
echo "Backup script is now starting -  $my_date"
# Call the check_script_location function
echo "Check script location:"
if [ "$(check_script_location "$DIR_INSTALLATION")" = "true" ]; then
    echo "[✓] Script located in: $DIR_SCRIPT_BACKUP"
else
    echo "[X] Script have to be executed from: $DIR_SCRIPT_BACKUP"
    exit 1
fi

echo "Check if all directories needed are present:"
check_required_files "$DIR_SCRIPT_LOGS" "$DIR_DB_BACKUP"
echo "Check if all files needed are present:"
check_required_files  "$RESTIC_BIN" "$RCLONE_BIN" "$RESTIC_CONF" "$RESTIC_PWD_FILE" "$OTHER_DBS_FILE" "$EXCLUDED_DIRS_FILE" "$OTHER_PGDBS_FILE"
#Protect the script directory - prevent access from the web
echo "Check .htaccess files content: "
create_htaccess_file "$DIR_SCRIPT_BACKUP" "$DIR_DB_BACKUP" 

#Dump WP DB 
dump_wordpress_databases --root-dir=$DIR_WP --backup-dir=$DIR_DB_BACKUP
#Dump other MySQL DB if any listed
dump_mysql_dbs $OTHER_DBS_FILE
#Dump other PostreSQL DB if any listed
dump_postgresql_dbs $OTHER_PGDBS_FILE
# Import the list of excluded directories to not backup.
echo "Search for folders and files to exclude from backup."
while read -r line; do
  if [[ "$line" != \#* ]]; then
    exclude_flags+=" --exclude $line"
  fi
done < "$EXCLUDED_DIRS_FILE"

# Restic will backup all directories located in $DIR_ROOT except the one listed for exclusion.
echo "Start to backup your data to your restic repo."
restic backup $DIR_ROOT --repo $restic_repo -p $RESTIC_PWD_FILE $exclude_flags
RESTIC_EXIT=$?
# On the 15th of the month we clean snapshot older than 3 months and we prune the repo
if [ "$(date +%d)" -eq $restic_clean_day ]; then
  echo "Removing restic snapshot older than $restic_keep_days days: "
  restic forget --keep-within-daily $restic_keep_days --repo $restic_repo -p $RESTIC_PWD_FILE
  # Prune the repository
  restic prune --repo $restic_repo -p $RESTIC_PWD_FILE
fi
#Cleanup old log files
delete_old_logs "$DIR_SCRIPT_LOGS" "$LOG_DAYS_TO_KEEP"
# Clean up old database backup files within the folder $DIR_DB_BACKUP
delete_old_dumps "$DIR_DB_BACKUP" "$DUMP_DAYS"
echo "Log file: $DIR_SCRIPT_LOGS/$restic_log_file"
echo "Sending the log file by email."
case $RESTIC_EXIT in
  0)
    RESTIC_EXIT_SBJ="O2Switch backup succeed: $restic_log_file"
    RESTIC_EXIT_MSG="Hi! Restic snapshot created successfully!"
    ;;
  1)
    RESTIC_EXIT_SBJ="O2Switch backup failed: $restic_log_file"
    RESTIC_EXIT_MSG="Hi! Fatal error: no snapshot created"
    ;;
  3)
    RESTIC_EXIT_SBJ="O2Switch backup incomplete: $restic_log_file"
    RESTIC_EXIT_MSG="Hi! Incomplete snapshot created: some source data could not be read"
    ;;
  *)
    RESTIC_EXIT_SBJ="O2Switch backup error: $restic_log_file"
    RESTIC_EXIT_MSG="Hi! Unknown error occurred"
    ;;
esac
echo $RESTIC_EXIT_MSG | mailx -s "$RESTIC_EXIT_SBJ" -a "$DIR_SCRIPT_LOGS/$restic_log_file" $restic_receive_email 
} 2>&1 | tee -- "$DIR_SCRIPT_LOGS/$restic_log_file"