# INSTALL
###########
# The sequence below is executed if the --install argument is being used.
echo "Starting the install of restic backup..."
check_and_backup_existing_files "$RESTIC_CONF" "$RESTIC_PWD_FILE" "$OTHER_DBS_FILE" "$OTHER_PGDBS_FILE" "$EXCLUDED_DIRS_FILE"
create_directories "$DIR_INSTALLATION" "$DIR_SCRIPT_LOGS" "$DIR_DB_BACKUP" "$DIR_SCRIPT_BINARIES" "$DIR_SCRIPT_CONFIGS" 
create_htaccess_file "$DIR_INSTALLATION" "$DIR_DB_BACKUP" 
install_restic
install_rclone
create_db_others_file
create_pgdb_others_file
create_file_exclude_directory
create_restic_conf_file
create_restic_pwd_file

if [ "$(check_script_location "$DIR_INSTALLATION")" = "false" ]; then
    echo "Copying backup script and associated files to the installation directory..."
    # Get the directory containing the backup.sh script
    current_script_dir="$(dirname "$(realpath "${BASH_SOURCE[1]}")")"
    # Ensure the target directory exists
    mkdir -p "$DIR_INSTALLATION"
    # Use rsync to copy all files and folders to the installation directory
    rsync -av --progress "$current_script_dir/" "$DIR_INSTALLATION/"
    echo "Files copied to the installation directory."
fi