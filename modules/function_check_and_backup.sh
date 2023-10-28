# Define function to check and potentially backup existing files
check_and_backup_existing_files() {
    local BACKUP_NEEDED=0
    for filepath in "$@"; do
        if [ -f "$filepath" ]; then
            echo "[!] Warning: File $filepath already exists."
            BACKUP_NEEDED=1
        fi
    done

    if [ $BACKUP_NEEDED -eq 1 ]; then
        echo ""
        echo "It seems you might have installed the script before."
        echo "Do you want to continue? If you do, the current content of $DIR_INSTALLATION will be copy to a new location."
        echo -n "Continue? (y/n): "
        read -r RESPONSE

        if [ "$RESPONSE" = "y" ]; then
            # Determine the backup directory name
            BACKUP_DIR="$DIR_INSTALLATION_scripts/backup_$(date +"%Y-%m-%d_%H-%M")"
            echo "[*] Creating backup directory: $BACKUP_DIR..."

            # Copy the current script install to a new backup directory
            cp -r "$DIR_INSTALLATION" "$BACKUP_DIR"
            
            if [ $? -eq 0 ]; then
                echo "[✓] Backup successful! Directory saved to: $BACKUP_DIR"
                rm -rf $DIR_INSTALLATION
            else
                echo "[X] Error: Failed to create backup directory."
                exit 1
            fi
        else
            echo "Installation aborted as per your choice."
            exit 1
        fi
    fi
}

# Sample call to the function
#check_and_backup_existing_files "$RESTIC_CONF" "$RESTIC_PWD_FILE" "$OTHER_DBS_FILE" "$OTHER_PGDBS_FILE" "$EXCLUDED_DIRS_FILE"