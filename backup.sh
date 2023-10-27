#!/bin/bash
# GitHub source: https://github.com/enzo-g/o2switch-backup-restic

# VARIABLES 
#############

# Define the root directory
DIR_ROOT="$HOME"
# Define the directory of your wordpress installations - default is $HOME
DIR_WP="$DIR_ROOT"
# Define the directory to store database dump
DIR_DB_BACKUP="$DIR_ROOT/backup-db"
# Define the path of the scripts directory
DIR_SCRIPTS="$DIR_ROOT/scripts"
# Define the path to the script backup directory
DIR_SCRIPT_BACKUP="$DIR_SCRIPTS/backup"
# Define the directory to store logs
DIR_SCRIPT_LOGS="$DIR_SCRIPT_BACKUP/logs"
# Define the directory of the action script
DIR_SCRIPT_ACTIONS="$DIR_SCRIPT_BACKUP/actions"
# Define the directory of the functions
DIR_SCRIPT_MODULES="$DIR_SCRIPT_BACKUP/modules"
# Define the directory of the binaries
DIR_SCRIPT_BINARIES="$DIR_SCRIPT_BACKUP/binaries"
# Define the directory of the config files
DIR_SCRIPT_CONFIGS="$DIR_SCRIPT_BACKUP/configs"
# Define the path to the Rclone binary
RCLONE_BIN="$DIR_SCRIPT_BINARIES/rclone"
# Define the path to the Restic binary
RESTIC_BIN="$DIR_SCRIPT_BINARIES/restic"
#Define the path of restic configuration
RESTIC_CONF="$DIR_SCRIPT_CONFIGS/backup-restic-conf.txt"
# Set the path to the Restic password file
RESTIC_PWD_FILE="$DIR_SCRIPT_CONFIGS/backup-restic-pwd.txt"
# Define the file containing other databases to backup and usernames
OTHER_DBS_FILE="$DIR_SCRIPT_CONFIGS/backup-db-others.txt"
# Define the file containing other databases to backup and usernames
OTHER_PGDBS_FILE="$DIR_SCRIPT_CONFIGS/backup-pgdb-others.txt"
# Define the file containing the directories to exclude
EXCLUDED_DIRS_FILE="$DIR_SCRIPT_CONFIGS/backup-excluded-dirs.txt"
# Add path of binary during script execution
export PATH=$PATH:$DIR_SCRIPT_BINARIES

# FUNCTIONS
#############

# Loop through each file in the modules directory and source it
for module in "$DIR_SCRIPT_MODULES"/*.sh; do
    if [ -f "$module" ]; then
        source "$module"
    fi
done

#Script execution
# Handle the provided arguments
case "$1" in
  --backup)
    # Execute the backup_action.sh script
    source "$DIR_SCRIPT_ACTIONS/action_backup.sh"
    ;;
  --install)
    # Execute the install_action.sh script
    source "$DIR_SCRIPT_ACTIONS/action_install.sh"
    ;;
  --help)
    # Display the help message
    source "$DIR_SCRIPT_ACTIONS/action_help.sh"
    ;;
  *)
    echo "Error: Invalid argument. Must be '--backup', '--install', or '--help'"
    exit 1
    ;;
esac