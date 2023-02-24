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

#############
# VARIABLES #
#############

# Define the root directory
ROOT_DIR="$HOME"

# Define the path to the script backup directory
RESTIC_SCRIPT="$ROOT_DIR/scripts/backup"

# Define the directory to store database backups
DB_BACKUP_DIR="$ROOT_DIR/backup-db"

# Add path of binary during script execution
export PATH=$PATH:$RESTIC_SCRIPT

# Define the path to the Rclone binary
RCLONE_BIN="$RESTIC_SCRIPT/rclone"

# Define the path to the Restic binary
RESTIC_BIN="$RESTIC_SCRIPT/restic"

#Define the path of restic configuration
RESTIC_CONF="$RESTIC_SCRIPT/backup-restic-conf.txt"

# Set the path to the Restic password file
restic_password_file="$RESTIC_SCRIPT/backup-restic-pwd.txt"

# Define the file containing other databases to backup and usernames
OTHER_DBS_FILE="$RESTIC_SCRIPT/backup-db-others.txt"

# Define the file containing the directories to exclude
EXCLUDED_DIRS_FILE="$RESTIC_SCRIPT/backup-excluded-dirs.txt"

################
#  FUNCTIONS   #
################

# Define function to create .htaccess file if it doesn't exist
function create_htaccess_file() {
  # Define the path to the .htaccess file
  HTACCESS_FILE="$1/.htaccess"

  # Create the .htaccess file if it does not exist
    if [ ! -f "$HTACCESS_FILE" ]; then
    echo "deny from all" > "$HTACCESS_FILE"
    echo ".htaccess file created at $HTACCESS_FILE"
  fi
}

function install_rclone {
  # Get the latest Restic release from GitHub
  LATEST_RCLONE=$(curl -s https://api.github.com/repos/rclone/rclone/releases/latest | grep -E '.*"browser_download_url":.*linux-amd64.zip"' | cut -d '"' -f 4)

  # Download the latest Restic release
  echo "Downloading latest release of Rclone..."
  curl -L -o $RESTIC_SCRIPT/rclone.zip $LATEST_RCLONE
  unzip -j $RESTIC_SCRIPT/rclone.zip "*rclone" -d $RESTIC_SCRIPT
  chmod +x $RESTIC_SCRIPT/rclone
  rm $RESTIC_SCRIPT/rclone.zip
  echo "Latest release of Rclone downloaded"
}

function install_restic {
  # Get the latest Restic release from GitHub
  LATEST_RESTIC=$(curl -s https://api.github.com/repos/restic/restic/releases/latest | grep -e "browser_download_url.*linux_amd64" | cut -d '"' -f 4)

  # Download the latest Restic release
  echo "Downloading latest release of Restic..."
  curl -L -o $RESTIC_SCRIPT/restic.bz2 $LATEST_RESTIC
  bunzip2 $RESTIC_SCRIPT/restic.bz2
  chmod +x $RESTIC_SCRIPT/restic
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
  # Check if the script is located in the backup directory "$HOME/scripts/backup"
  if [ "$(dirname "$(realpath "$0")")" = "$RESTIC_SCRIPT" ]; then
    is_script_in_backup_dir=true
  else
    is_script_in_backup_dir=false
  fi
}

function copy_script_to_backup_dir() {
  # Get the current location of the script
  SCRIPT_LOCATION=$(realpath "$0")
  # Copy the script to the backup directory
    cp "$SCRIPT_LOCATION" "$RESTIC_SCRIPT/"
  chmod +x "$RESTIC_SCRIPT/backup.sh"
}

function create_db_others_file() {
  # Check if the db-others file exists, if not create it with sample content
  if [ ! -f "$OTHER_DBS_FILE" ]; then
    echo "# To backup other databases not related to WordPress, add lines to this file in the following format:
    # dbname;username;password
    # Example:
    # mydb1;myuser1;mypassword1
    # mydb2;myuser2;mypassword2" > "$OTHER_DBS_FILE"
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

function create_restic_files (){
  # Create the Restic configuration file if it does not exist
  if [ ! -f "$RESTIC_CONF" ]; then
    echo "# Set the Restic repository
    restic_repo=\"sftp:user_remoteserver@host_remoteserver.com:/home/user_remoteserver/restic\"" > "$RESTIC_CONF"
  fi

  # Create the Restic password file if it doesn't exist and add sample content
  if [ ! -f "$restic_password_file" ]; then
    echo "INPUT_YOUR_RESTIC_REPO_PASSWORD_HERE" > "$restic_password_file"
    echo "Restic password file created at $restic_password_file, edit it before to launch the backup script again"
    exit 1
  fi
}

function check_required_files() {
  local files=("$DB_BACKUP_DIR" "$RESTIC_BIN" "$RCLONE_BIN" "$RESTIC_CONF" "$restic_password_file" "$OTHER_DBS_FILE" "$EXCLUDED_DIRS_FILE")
  for file in "${files[@]}"; do
    if [ ! -e "$file" ]; then
      echo "Error: $file does not exist. All file declared within the function check_required_files have to be present"
      exit 1
    fi
  done
}

############################
#Installation of the script#
############################

if [ "$1" = "--install" ]; then
  echo "Starting the install of restic backup..."
  create_mandatory_dir "$ROOT_DIR/scripts" "check"
  create_mandatory_dir "$RESTIC_SCRIPT" "check"
  create_htaccess_file "$RESTIC_SCRIPT"
  create_mandatory_dir "$DB_BACKUP_DIR"
  create_htaccess_file "$DB_BACKUP_DIR"
  install_restic
  install_rclone
  create_db_others_file
  create_file_exclude_directory
  create_restic_files
  if [ "$is_script_in_backup_dir" = false ]; then
      echo "We copy the script in the dir:$RESTIC_SCRIPT"
      copy_script_to_backup_dir
      echo "You can now delete the script from $SCRIPT_LOCATION"
  fi

fi

############################
#        Backup            #
############################

if [ "$1" = "--backup" ]; then
  my_date=$(date +"%Y-%m-%d %H:%M")
  echo "Backup script is now starting -  $my_date"
  # Call the check_script_location function
  is_script_in_backup_dir
  if [ "$is_script_in_backup_dir" = true ]; then
      echo "The script is located in the backup directory as it should."
  else
      echo "The script is not located in the backup directory. Executed the script from the backup directory location: $RESTIC_SCRIPT"
      exit 1
  fi
  #Protect the script directory - prevent access from the web
  echo "Check if a .htaccess file protect the direcotry $RESTIC_SCRIPT"
  create_htaccess_file "$RESTIC_SCRIPT"
  echo "Check if a .htaccess file protect the direcotry $DB_BACKUP_DIR"
  create_htaccess_file "$DB_BACKUP_DIR"
  echo "Check if all files needed for the script to execute properly are present"
  check_required_files

  # Loop over directories in the root directory to find wordpress installation and dump their DB
  for INSTALLATION_DIR in "$ROOT_DIR"/*/; do
    if [ -f "$INSTALLATION_DIR/wp-config.php" ]; then
        echo "Starting to dump the DB for WordPress installation detected: $INSTALLATION_DIR"
        DATABASE=$(grep "define('DB_NAME'" "$INSTALLATION_DIR/wp-config.php" | cut -d "'" -f 4)
        DB_USER=$(grep "define('DB_USER'" "$INSTALLATION_DIR/wp-config.php" | cut -d "'" -f 4)
        DB_PASSWORD=$(grep "define('DB_PASSWORD'" "$INSTALLATION_DIR/wp-config.php" | cut -d "'" -f 4)
        if [ -n "$DATABASE" ]; then
            DATE=$(date +"%Y-%m-%d")
            TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
            DUMP_FILE="${DATABASE}_${DATE}_${TIMESTAMP}.sql"
            mysqldump --user=$DB_USER --password=$DB_PASSWORD --databases $DATABASE > "$DB_BACKUP_DIR/$DUMP_FILE"
            gzip "$DB_BACKUP_DIR/$DUMP_FILE"
        fi
    fi
  done
  
  # Backup databases not related to WordPress installation
  if [ -f "$OTHER_DBS_FILE" ] && [ -s "$OTHER_DBS_FILE" ]; then
  echo "Start to dump the databases present in the file $OTHER_DBS_FILE"
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
      mysqldump --user=$DB_USER --password=$DB_PASSWORD --databases $DB_NAME > "$DB_BACKUP_DIR/$DUMP_FILE"
      gzip "$DB_BACKUP_DIR/$DUMP_FILE"
  done < "$OTHER_DBS_FILE"
  else
  echo "The is no other databases dump required based on the file $OTHER_DBS_FILE"
  fi

  # Read the excluded directories from the file
  if [ -f "$EXCLUDED_DIRS_FILE" ]; then
    echo "Reading excluded directories from file: $EXCLUDED_DIRS_FILE"
  else
    echo "Error: excluded directories file not found: $EXCLUDED_DIRS_FILE"
    exit 1
  fi
  while read -r line; do
    if [[ "$line" != \#* ]]; then
      exclude_flags+=" --exclude $line"
    fi
  done < "$EXCLUDED_DIRS_FILE"

  # Load Restic configuration
  if [ -f "$RESTIC_CONF" ]; then
  . "$RESTIC_CONF"
  else
  echo "Restic configuration file not found: $RESTIC_CONF"
  exit 1
  fi

  # Create a backup with Restic for each directory
  echo "We start to backup the files to the external repository with restic.."
  restic backup $ROOT_DIR --repo $restic_repo -p $restic_password $exclude_flags

  # On the 15th of the month we clean snapshot older than 3 months and we prune the repo
  if [ "$(date +%d)" -eq 15 ]; then
  # Remove snapshot older than 3 months
  restic forget --keep-daily 90 --keep-monthly 3 --repo $restic_repo -p $restic_password
  # Prune the repository
  restic prune --repo $restic_repo -p $restic_password
  fi

  # Clean up old database backup files within the folder $DB_BACKUP_DIR (that's not deleting them directly from restic repo)
  find "$DB_BACKUP_DIR" -name "*.sql.gz" -type f -mtime +15 -delete
fi