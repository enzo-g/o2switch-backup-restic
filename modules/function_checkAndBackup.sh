# This function takes one or more file paths as arguments
# For each file, it checks if it exists, prompts the user for overwriting,
# and if the user agrees, backs up the file with the current date appended.
check_and_backup() {
    for file in "$@"; do
        # Check if file exists
        if [ -f "$file" ]; then
            echo "File $file already exists."
            read -p "Do you want to overwrite $file? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                backup_file="$file_$(date +"%Y%m%d").bak"
                cp "$file" "$backup_file"
                if [ $? -eq 0 ]; then
                    echo "Backup of $file created at $backup_file"
                else
                    echo "Failed to create a backup for $file. Aborting."
                    exit 1
                fi
            else
                echo "Operation aborted for $file by the user."
                exit 1
            fi
        fi
    done
}

# Example usage:
# check_and_backup "$RESTIC_CONF" "$DIR_SCRIPT_BACKUPSH"
