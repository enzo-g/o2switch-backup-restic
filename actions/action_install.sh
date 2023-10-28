# INSTALL
###########
# The sequence below is executed if the --install argument is being used.
echo "Starting the install of restic backup..."
check_and_backup_existing_files "$RESTIC_CONF" "$RESTIC_PWD_FILE" "$OTHER_DBS_FILE" "$OTHER_PGDBS_FILE" "$EXCLUDED_DIRS_FILE"
create_directories "$DIR_SCRIPTS" "$DIR_SCRIPT_BACKUP" "$DIR_SCRIPT_LOGS" "$DIR_DB_BACKUP" "$DIR_SCRIPT_BINARIES"
create_htaccess_file "$DIR_SCRIPT_BACKUP" "$DIR_DB_BACKUP" 
install_restic
install_rclone
create_db_others_file
create_pgdb_others_file
create_file_exclude_directory
create_restic_conf_files
create_restic_pwd_file