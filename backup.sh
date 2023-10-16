#!/bin/bash
# GitHub source: https://github.com/enzo-g/o2switch-backup-restic

#Argument you can use with the script

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <--backup|--install>"
  exit 1
fi

if [ "$1" != "--backup" ] && [ "$1" != "--install" ]; then
  echo "Error: Invalid argument. Must be '--backup' or '--install'"
  exit 1
fi

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
# Define the path to the Rclone binary
RCLONE_BIN="$DIR_SCRIPT_BACKUP/rclone"
# Define the path to the Restic binary
RESTIC_BIN="$DIR_SCRIPT_BACKUP/restic"
#Define the path of restic configuration
RESTIC_CONF="$DIR_SCRIPT_BACKUP/backup-restic-conf.txt"
# Set the path to the Restic password file
RESTIC_PWD_FILE="$DIR_SCRIPT_BACKUP/backup-restic-pwd.txt"
# Define the file containing other databases to backup and usernames
OTHER_DBS_FILE="$DIR_SCRIPT_BACKUP/backup-db-others.txt"
# Define the file containing other databases to backup and usernames
OTHER_PGDBS_FILE="$DIR_SCRIPT_BACKUP/backup-pgdb-others.txt"
# Define the file containing the directories to exclude
EXCLUDED_DIRS_FILE="$DIR_SCRIPT_BACKUP/backup-excluded-dirs.txt"
# Add path of binary during script execution
export PATH=$PATH:$DIR_SCRIPT_BACKUP

# FUNCTIONS
#############

# Define function to create .htaccess file if it doesn't exist, overwrite it if the content is not correct.
function create_htaccess_file() {
  # Define the path to the .htaccess file
  HTACCESS_FILE="$1/.htaccess"
  DESIRED_CONTENT="deny from all"

  if [ -f "$HTACCESS_FILE" ]; then
    # If the file exists, check if its content matches the desired content
    if [ "$(cat "$HTACCESS_FILE")" == "$DESIRED_CONTENT" ]; then
      # If the content matches, display a message and return
      echo "[✓] Content up-to-date for: $HTACCESS_FILE"
      return
    else
      # If the content is different, display a message and overwrite the file
      echo "$DESIRED_CONTENT" > "$HTACCESS_FILE"
      echo "[!] Content updated to correct value for $HTACCESS_FILE"
      return
    fi
  else
    # If the file does not exist, create it with the desired content and display a message
    echo "[X] File missing: $HTACCESS_FILE."
    echo "$DESIRED_CONTENT" > "$HTACCESS_FILE"
    if [ -f "$HTACCESS_FILE" ]; then
      echo "[!] File created: $HTACCESS_FILE."
    else
      echo "[X] Error: Failed to create .htaccess file: $HTACCESS_FILE"
      exit 1
    fi
    return
  fi
}

function delete_old_logs() {
  COUNT0=$(find "$DIR_SCRIPT_LOGS" -type f -name "*.txt" -mtime +$LOG_DAYS_TO_KEEP | wc -l)
  if [ $COUNT0 -gt 0 ]; then
    echo "Deleting log files that are $LOG_DAYS_TO_KEEP days old or older."
    find "$DIR_SCRIPT_LOGS" -type f -name "*.txt" -mtime +$LOG_DAYS_TO_KEEP -delete
  fi
}

function delete_old_dumps() {
  # Count the number of files to be deleted
  COUNT=$(find "$DIR_DB_BACKUP" -name "*.sql.gz" -type f -mtime +$DUMP_DAYS | wc -l)
  # Output the echo message only if there are files to be deleted
  if [ $COUNT -gt 0 ]; then
    echo "Deleting database dump files that are $DUMP_DAYS days old or older."
    find "$DIR_DB_BACKUP" -name "*.sql.gz" -type f -mtime +$DUMP_DAYS -exec rm {} \;
  fi
}

function install_rclone {
  # Get the latest Restic release from GitHub
  LATEST_RCLONE=$(curl -s https://api.github.com/repos/rclone/rclone/releases/latest | grep -E '.*"browser_download_url":.*linux-amd64.zip"' | cut -d '"' -f 4)

  # Download the latest Restic release
  echo "Downloading latest release of Rclone..."
  curl -L -o $DIR_SCRIPT_BACKUP/rclone.zip $LATEST_RCLONE
  unzip -j $DIR_SCRIPT_BACKUP/rclone.zip "*rclone" -d $DIR_SCRIPT_BACKUP
  chmod +x $DIR_SCRIPT_BACKUP/rclone
  rm $DIR_SCRIPT_BACKUP/rclone.zip
  echo "Latest release of Rclone downloaded"
}

function install_restic {
  # Get the latest Restic release from GitHub
  LATEST_RESTIC=$(curl -s https://api.github.com/repos/restic/restic/releases/latest | grep -e "browser_download_url.*linux_amd64" | cut -d '"' -f 4)

  # Download the latest Restic release
  echo "Downloading latest release of Restic..."
  curl -L -o $DIR_SCRIPT_BACKUP/restic.bz2 $LATEST_RESTIC
  bunzip2 $DIR_SCRIPT_BACKUP/restic.bz2
  chmod +x $DIR_SCRIPT_BACKUP/restic
  echo "Latest release of Restic downloaded"
}

function create_mandatory_dir() {
  dir_path="$1"
  notify="$2"

  if [ ! -d "$dir_path" ]; then
    echo "Creating directory: $dir_path"
    mkdir -p "$dir_path"
  else
    if [ "$notify" == "check" ] && [ "$(ls -A "$dir_path")" ]; then
      echo "Warning: Directory $dir_path already exists and is not empty."
    fi
  fi
}

# Function to check if script is located in the backup directory
function is_script_in_backup_dir() {
  # Check if the script is located in the backup directory "$DIR_SCRIPT_BACKUP"
  if [ "$(dirname "$(realpath "$0")")" = "$DIR_SCRIPT_BACKUP" ]; then
    is_script_in_backup_dir=true
  else
    is_script_in_backup_dir=false
  fi
}

function copy_script_to_backup_dir() {
  # Get the current location of the script
  SCRIPT_LOCATION=$(realpath "$0")
  # Copy the script to the backup directory
    cp "$SCRIPT_LOCATION" "$DIR_SCRIPT_BACKUP/"
  chmod +x "$DIR_SCRIPT_BACKUP/backup.sh"
}

function create_db_others_file() {
  # Check if the db-others file exists, if not create it with sample content
  if [ ! -f "$OTHER_DBS_FILE" ]; then
    echo "# To backup other databases not related to WordPress, add lines to this file in the following format:" \
    "# dbname;username;password" \
    "# Example:" \
    "# mydb1;myuser1;mypassword1" \
    "# mydb2;myuser2;mypassword2" > "$OTHER_DBS_FILE"
  fi
} 

function create_pgdb_others_file() {
  # Check if the db-others file exists, if not create it with sample content
  if [ ! -f "$OTHER_PGDBS_FILE" ]; then
    echo "# This file is to backup PostGreSQL DB, add lines to this file in the following format:" \
    "# dbname;username;password" \
    "# Example:" \
    "# mydb1;myuser1;mypassword1" \
    "# mydb2;myuser2;mypassword2" > "$OTHER_PGDBS_FILE"
  fi
} 

function create_file_exclude_directory (){
  # Create the excluded directories file if it doesn't exist
  if [ ! -f "$EXCLUDED_DIRS_FILE" ]; then
    echo "$HOME/scripts" >> "$EXCLUDED_DIRS_FILE"
    echo "$HOME/mail" >> "$EXCLUDED_DIRS_FILE"
    echo "$HOME/log" >> "$EXCLUDED_DIRS_FILE"
    echo "$HOME/etc" >> "$EXCLUDED_DIRS_FILE"
    echo "$HOME/ssl" >> "$EXCLUDED_DIRS_FILE"
    echo "$HOME/tmp" >> "$EXCLUDED_DIRS_FILE"
    echo "#You can get the path of all hidden directory by executing the following command while in your home directory:" >> "$EXCLUDED_DIRS_FILE"
    echo "#ls -dA .*/ | grep -Ev '^(\./|\.\./)$'" >> "$EXCLUDED_DIRS_FILE"
  fi
}

function create_restic_conf_files {
  if [ -f "$RESTIC_CONF" ]; then
    # Put all the content of the file in comment
    sed -i 's/^/# /' $RESTIC_CONF
    # Echo a message to ask the user to review the content of the file
    echo '[!] File already exist: $RESTIC_CONF '
    echo "[!] Your previous settings will be commented out"
    echo '# Please review the previous settings before making changes:' >> $RESTIC_CONF
    echo "# (Your previous settings are commented out)" >> $RESTIC_CONF
    echo '# ' >> $RESTIC_CONF
    echo "# $(date +"%Y-%m-%d %H:%M:%S") - Settings added by script" >> $RESTIC_CONF
    echo '# ' >> $RESTIC_CONF
  else
    # Add new settings to the file
    echo '# Set the Restic repository' >> $RESTIC_CONF
    echo 'restic_repo="sftp:user_remoteserver@host_remoteserver.com:/home/user_remoteserver/restic"' >> $RESTIC_CONF
    echo '#restic_repo="rclone:example:O2switch/R1"' >> $RESTIC_CONF
    echo '# Define how many days of backup restic should preserve' >> $RESTIC_CONF
    echo 'restic_keep_days=90d' >> $RESTIC_CONF
    echo '# Define which day of the month, restic should clean the backup repository' >> $RESTIC_CONF
    echo 'restic_clean_day=15' >> $RESTIC_CONF
    echo '# Define log file name' >> $RESTIC_CONF
    echo 'restic_log_file=$(date +"%Y-%m-%d-%H-%M")"_backup.txt"' >> $RESTIC_CONF
    echo '# Define how many days we keep the log files' >> $RESTIC_CONF
    echo 'restic_log_days=90' >> $RESTIC_CONF
    echo '# Define how many days we keep the MySQL dump' >> $RESTIC_CONF
    echo 'restic_dump_days=15' >> $RESTIC_CONF
    echo '# DEFINE RECEIVER EMAIL' >> $RESTIC_CONF
    echo 'restic_receive_email="user@example.com"' >> $RESTIC_CONF
  fi
  # Create the Restic password file if it doesn't exist and add sample content
  if [ ! -f "$RESTIC_PWD_FILE" ]; then
    echo "INPUT_YOUR_RESTIC_REPO_PASSWORD_HERE" > "$RESTIC_PWD_FILE"
    echo "Restic password file created at $RESTIC_PWD_FILE, edit it before to launch the backup script again"
    exit 1
  fi
}

function check_required_files() {
  local paths=("$@")
  local error=0
  for path in "${paths[@]}"; do
    if [ -e "$path" ]; then
      if [ -d "$path" ]; then
        echo "[✓] Directory found: $path "
      else
        echo "[✓] File found: $path "
      fi
    else
      if [ -d "$path" ]; then
        echo "[X] Directory not found: $path"
      else
        echo "[X] File not found: $path"
      fi
      error=1
    fi
  done
  if [ $error -eq 1 ]; then
    exit 1
  fi
}

function dump_wordpress_databases() {
  local ROOT_DIR=""
  local BACKUP_DIR=""
  local count=0

  echo "Search for Wordpress DB to dump: "

  # Parse arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      --root-dir=*)
        ROOT_DIR="${1#*=}"
        ;;
      --backup-dir=*)
        BACKUP_DIR="${1#*=}"
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
    shift
  done

  # Check that both arguments are present
  if [ -z "$ROOT_DIR" ] || [ -z "$BACKUP_DIR" ]; then
    echo "Usage: dump_wordpress_databases --root-dir=ROOT_DIR --backup-dir=BACKUP_DIR"
    exit 1
  fi

  # Count the number of WordPress installations in $ROOT_DIR
  for INSTALLATION_DIR in "$ROOT_DIR"/*/; do
    if [ -f "$INSTALLATION_DIR/wp-config.php" ]; then
      count=$((count+1))
    fi
  done
  
  # Output the number of installations found or a message if none are found
  if [ $count -eq 0 ]; then
    echo "No WordPress installations found in $ROOT_DIR"
  else
    echo "$count WordPress DB found"
  fi

  # Dump the databases for each WordPress installation
  for INSTALLATION_DIR in "$ROOT_DIR"/*/; do
    if [ -f "$INSTALLATION_DIR/wp-config.php" ]; then
      # Extract the database connection details from wp-config.php
      DATABASE=$(grep -oP "define\(\s*'DB_NAME'\s*,\s*'\K[^']+" "$INSTALLATION_DIR/wp-config.php")
      DB_USER=$(grep -oP "define\(\s*'DB_USER'\s*,\s*'\K[^']+" "$INSTALLATION_DIR/wp-config.php")
      DB_PASSWORD=$(grep -oP "define\(\s*'DB_PASSWORD'\s*,\s*'\K[^']+" "$INSTALLATION_DIR/wp-config.php")
      # If a database name is found, create a backup file
      if [ -n "$DATABASE" ]; then
        DATE=$(date +"%Y-%m-%d")
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        DUMP_FILE="${DATABASE}_${DATE}_${TIMESTAMP}.sql"
        if mysqldump --user="$DB_USER" --password="$DB_PASSWORD" --databases "$DATABASE" > "$BACKUP_DIR/$DUMP_FILE"; then
          gzip "$BACKUP_DIR/$DUMP_FILE"
          echo "[✓] Dump succeed for: $INSTALLATION_DIR"
        else
          echo "[X] Dump failed for: $INSTALLATION_DIR"
        fi
      fi
    fi
  done
}

dump_mysql_dbs() {
  local FILE="$1"
  local NUM_DBS=0

  echo "Search if specific DB has been listed for backup:"
  # Backup databases not related to WordPress installation
  if [ -f "$FILE" ] && [ -s "$FILE" ]; then
    NUM_DBS=$(grep -v "^#" "$FILE" | wc -l)
    echo "$NUM_DBS DB to backup based on $FILE"

    while read -r LINE; do
      if [[ "$LINE" == \#* ]]; then
        # Skip commented lines
        continue
      fi
      DB_NAME=$(echo "$LINE" | cut -d ";" -f 1)
      DB_USER=$(echo "$LINE" | cut -d ";" -f 2)
      DB_PASSWORD=$(echo "$LINE" | cut -d ";" -f 3)
      DATE=$(date +"%Y-%m-%d")
      TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
      DUMP_FILE="${DB_NAME}_${DATE}_${TIMESTAMP}.sql"
      if mysqldump --user=$DB_USER --password=$DB_PASSWORD --databases $DB_NAME > "$DIR_DB_BACKUP/$DUMP_FILE"; then
        echo "[✓] Dump succeed for: $DB_NAME"
        gzip "$DIR_DB_BACKUP/$DUMP_FILE"
      else
        echo "[X] Dump failed for: $DB_NAME"
      fi
    done < "$FILE"
  else
    echo "[✓] No other DB dump required based on: $FILE"
  fi
}

dump_postgresql_dbs() {
  local FILE="$1"
  local NUM_DBS=0

  echo "Search if specific PostGreSQL DB has been listed for backup:"

  # Backup databases not related to WordPress installation
  if [ -f "$FILE" ] && [ -s "$FILE" ]; then
    NUM_DBS=$(grep -v "^#" "$FILE" | wc -l)
    echo "$NUM_DBS DB to backup based on $FILE"

    while read -r LINE; do
      if [[ "$LINE" == \#* ]]; then
        # Skip commented lines
        continue
      fi

      DB_NAME=$(echo "$LINE" | cut -d ";" -f 1)
      DB_USER=$(echo "$LINE" | cut -d ";" -f 2)
      DB_PASSWORD=$(echo "$LINE" | cut -d ";" -f 3)

      DATE=$(date +"%Y-%m-%d")
      TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
      DUMP_FILE="${DB_NAME}_${DATE}_${TIMESTAMP}.sql"
      if PGPASSWORD="$DB_PASSWORD" pg_dump --username="$DB_USER" --file="$DIR_DB_BACKUP/$DUMP_FILE" --format=custom "$DB_NAME"; then
        echo "[✓] Dump succeed for: $DB_NAME"
        gzip "$DIR_DB_BACKUP/$DUMP_FILE"
      else
        echo "[X] Dump failed for: $DB_NAME"
      fi
    done < "$FILE"
  else
    echo "[✓] No other PostGreSQL DB dump required based on: $FILE"
  fi
}

# SCRIPT'S INSTALLATION
#########################
# The sequence below is executed if the --install argument is being used.
if [ "$1" = "--install" ]; then
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
fi

# BACKUP  
##########
# The sequence below is executed if the --backup argument is being used.
if [ "$1" = "--backup" ]; then
    
    #VARIABLES LOADED FROM EXTERNAL FILE
    #####################################
    # Load RESTIC CONF
    echo "Load variables from: $RESTIC_CONF"
    if [ -f "$RESTIC_CONF" ]; then
      echo "[✓] Restic configuration file found: $RESTIC_CONF"
      . "$RESTIC_CONF"
    else
      echo "[X] Restic configuration file not found: $RESTIC_CONF"
      echo "[!] Have you run backup.sh --install previously?"
      exit 1
    fi

    RESTIC_CONF_REPO=$restic_repo
    #Define log file name
    LOG_FILE=$restic_log_file
    #Define how many days we keep the log files
    LOG_DAYS_TO_KEEP=$restic_log_days
    #Define how many days we keep the MySQL dump - Not related to restic backup.
    DUMP_DAYS=$restic_dump_days
    #DEFINE EMAIL
    EMAIL=$restic_receive_email

  # Redirect all output to the log file and the terminal    
  {
    my_date=$(date +"%Y-%m-%d %H:%M")
    echo "Backup script is now starting -  $my_date"
    # Call the check_script_location function
    echo "Check script location:"
    is_script_in_backup_dir
    if [ "$is_script_in_backup_dir" = true ]; then
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
    create_htaccess_file "$DIR_SCRIPT_BACKUP"
    create_htaccess_file "$DIR_DB_BACKUP"

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
    # Clean up old database backup files within the folder $DIR_DB_BACKUP (that's not deleting them directly from restic repo)
    delete_old_dumps
    #Cleanup old log files
    delete_old_logs
    echo "Log file: $DIR_SCRIPT_LOGS/$LOG_FILE"
    echo "Sending the log file by email."
    case $RESTIC_EXIT in
      0)
        RESTIC_EXIT_SBJ="O2Switch backup succeed: $LOG_FILE"
        RESTIC_EXIT_MSG="Hi! Restic snapshot created successfully!"
        ;;
      1)
        RESTIC_EXIT_SBJ="O2Switch backup failed: $LOG_FILE"
        RESTIC_EXIT_MSG="Hi! Fatal error: no snapshot created"
        ;;
      3)
        RESTIC_EXIT_SBJ="O2Switch backup incomplete: $LOG_FILE"
        RESTIC_EXIT_MSG="Hi! Incomplete snapshot created: some source data could not be read"
        ;;
      *)
        RESTIC_EXIT_SBJ="O2Switch backup error: $LOG_FILE"
        RESTIC_EXIT_MSG="Hi! Unknown error occurred"
        ;;
    esac
    echo $RESTIC_EXIT_MSG | mailx -s "$RESTIC_EXIT_SBJ" -a "$DIR_SCRIPT_LOGS/$LOG_FILE" $EMAIL 
  } 2>&1 | tee -- "$DIR_SCRIPT_LOGS/$LOG_FILE"
fi
