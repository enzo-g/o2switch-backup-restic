function create_restic_conf_files {
  if [ -f "$RESTIC_CONF" ]; then
    # Ask the user if they want to alter the current conf file
    echo "Do you want to alter the current conf file? (y/n): "
    echo "[Note: If you say 'yes', the current conf and password files will be backed up. If 'no', the process will be stopped.]"
    read -r RESPONSE
    if [ "$RESPONSE" = "y" ]; then
      # Backup the current conf file with current date and hour
      cp "$RESTIC_CONF" "${RESTIC_CONF}_$(date +"%Y-%m-%d-%H-%M").backup"
      if [ $? -ne 0 ]; then
        echo "Error while backing up the conf file. Exiting..."
        exit 1
      fi
      echo "[!] Backup of the previous settings saved to: ${RESTIC_CONF}_$(date +"%Y-%m-%d-%H-%M").backup"

      # Backup the password file
      if [ -f "$RESTIC_PWD_FILE" ]; then
        cp "$RESTIC_PWD_FILE" "${RESTIC_PWD_FILE}_$(date +"%Y-%m-%d-%H-%M").backup"
        if [ $? -ne 0 ]; then
          echo "Error while backing up the password file. Exiting..."
          exit 1
        fi
        echo "[!] Backup of the previous password saved to: ${RESTIC_PWD_FILE}_$(date +"%Y-%m-%d-%H-%M").backup"
      fi
    else
      echo "Exiting the script as per your choice."
      exit 1
    fi
  fi

  # Overwrite the settings in the conf file
  echo '# Set the Restic repository' > "$RESTIC_CONF"
  echo 'restic_repo="sftp:user_remoteserver@host_remoteserver.com:/home/user_remoteserver/restic"' >> "$RESTIC_CONF"
  echo '#restic_repo="rclone:example:O2switch/R1"' >> "$RESTIC_CONF"
  echo '# Define how many days of backup restic should preserve' >> "$RESTIC_CONF"
  echo 'restic_keep_days=90d' >> "$RESTIC_CONF"
  echo '# Define which day of the month, restic should clean the backup repository' >> "$RESTIC_CONF"
  echo 'restic_clean_day=15' >> "$RESTIC_CONF"
  echo '# Define log file name' >> "$RESTIC_CONF"
  echo 'restic_log_file=$(date +"%Y-%m-%d-%H-%M")"_backup.txt"' >> "$RESTIC_CONF"
  echo '# Define how many days we keep the log files' >> "$RESTIC_CONF"
  echo 'restic_log_days=90' >> "$RESTIC_CONF"
  echo '# Define how many days we keep the MySQL dump' >> "$RESTIC_CONF"
  echo 'restic_dump_days=15' >> "$RESTIC_CONF"
  echo '# DEFINE RECEIVER EMAIL' >> "$RESTIC_CONF"
  echo 'restic_receive_email="user@example.com"' >> "$RESTIC_CONF"
  
  # If the password file does not exist, create it
  if [ ! -f "$RESTIC_PWD_FILE" ]; then
    echo "INPUT_YOUR_RESTIC_REPO_PASSWORD_HERE" > "$RESTIC_PWD_FILE"
    echo "Restic password file created at $RESTIC_PWD_FILE, edit it before launching the backup script again"
    exit 1
  fi
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