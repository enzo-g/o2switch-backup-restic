# INSTALL
###########
# The sequence below is executed if the --install argument is being used.
echo "Starting the install of restic backup..."
create_directories "$DIR_SCRIPTS" "$DIR_SCRIPT_BACKUP" "$DIR_SCRIPT_LOGS" "$DIR_DB_BACKUP"
create_htaccess_file "$DIR_SCRIPT_BACKUP" "$DIR_DB_BACKUP" 
install_restic
install_rclone
create_db_others_file
create_pgdb_others_file
create_file_exclude_directory
create_restic_conf_files
create_restic_pwd_file

#We only copy the script to the backup directory at the end of the install.
if [ "$is_script_in_backup_dir" = false ]; then
    echo "We copy the script in the dir:$DIR_SCRIPT_BACKUP"
    copy_script_to_backup_dir
    echo "Now deleting the script from $SCRIPT_LOCATION"
    rm "$(realpath "$0")"
fi