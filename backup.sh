#!/bin/bash

# VARIABLES 
#############

# Get the directory of the currently executing script
DIR_SCRIPT="$(dirname "$(readlink -f "$0")")"
# Define the root directory
DIR_ROOT="$HOME"
# Define the installation directory for the scripts in general
DIR_INSTALLATION_scripts="$HOME/scripts"
# Define the installation directory for the script backup
DIR_INSTALLATION="$HOME/scripts/backup"
# Define the directory of your wordpress installations - default is $HOME
DIR_WP="$DIR_ROOT"
# Define the directory to store database dump
DIR_DB_BACKUP="$DIR_ROOT/backup-db"
# Define the directory of the action script relative to the executing script
DIR_SCRIPT_ACTIONS="$DIR_SCRIPT/actions"
# Define the directory of the functions relative to the executing script
DIR_SCRIPT_MODULES="$DIR_SCRIPT/modules"
# Define the directory to store logs
DIR_SCRIPT_LOGS="$DIR_INSTALLATION/logs"
# Define the directory of the binaries (assuming the binaries are within the 'backup' directory in the repo)
DIR_SCRIPT_BINARIES="$DIR_INSTALLATION/binaries"
# Define the directory of the config files
DIR_SCRIPT_CONFIGS="$DIR_INSTALLATION/configs"
# Define the path to the Rclone binary
RCLONE_BIN="$DIR_SCRIPT_BINARIES/rclone"
# Define the path to the Restic binary
RESTIC_BIN="$DIR_SCRIPT_BINARIES/restic"
# Define the path of restic configuration
RESTIC_CONF="$DIR_SCRIPT_CONFIGS/backup-restic-conf.conf"
# Set the path to the Restic password file
RESTIC_PWD_FILE="$DIR_SCRIPT_CONFIGS/backup-restic-pwd.conf"
# Define the file containing other databases to backup and usernames
OTHER_DBS_FILE="$DIR_SCRIPT_CONFIGS/backup-db-others.conf"
# Define the file containing other databases to backup and usernames
OTHER_PGDBS_FILE="$DIR_SCRIPT_CONFIGS/backup-pgdb-others.conf"
# Define the file containing the directories to exclude
EXCLUDED_DIRS_FILE="$DIR_SCRIPT_CONFIGS/backup-excluded-dirs.conf"
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

# Script execution
# Handle the provided arguments
case "$1" in
  --restore)
    # Execute the backup_action.sh script
    source "$DIR_SCRIPT_ACTIONS/action_restore.sh"
    ;;
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
    echo "Error: Invalid argument. Must be '--backup', '--install', or '--help', or '--restore'"
    exit 1
    ;;
esac
