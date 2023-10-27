# INSTALL
###########
# The sequence below is executed if the --install argument is being used.
echo "Starting the install of restic backup..."
create_mandatory_dir "$DIR_SCRIPTS" "check"
create_mandatory_dir "$DIR_SCRIPT_BACKUP" "check"
create_mandatory_dir "$DIR_SCRIPT_LOGS" "check"
create_mandatory_dir "$DIR_DB_BACKUP"
create_htaccess_file "$DIR_SCRIPT_BACKUP"  
create_htaccess_file "$DIR_DB_BACKUP"
install_restic
install_rclone
create_db_others_file
create_pgdb_others_file
create_file_exclude_directory
create_restic_conf_files
if [ "$is_script_in_backup_dir" = false ]; then
    echo "We copy the script in the dir:$DIR_SCRIPT_BACKUP"
    copy_script_to_backup_dir
    echo "Now deleting the script from $SCRIPT_LOCATION"
    rm "$(realpath "$0")"
fi