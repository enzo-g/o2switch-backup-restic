# RESTORE
###########
# The sequence below is executed if the --restore argument is being used.
echo "Load variables from: $RESTIC_CONF"
if [ -f "$RESTIC_CONF" ]; then
  source "$RESTIC_CONF"
else
  echo "[X] Restic configuration file not found: $RESTIC_CONF"
  echo "[!] Have you run backup.sh --install previously?"
  exit 1
fi

while true; do
    clear
    echo "Welcome to the interactive restoration menu"
    echo "==========================================="
    echo "1. View snapshots"
    echo "2. List files in a snapshot"
    echo "3. Restore from a snapshot"
    echo "4. Monitor ongoing restoration"
    echo "5. Stop an ongoing restoration"
    echo "6. Exit"
    echo "==========================================="
    read -p "Select an option: " CHOICE

    case $CHOICE in
        1)
            restic -r $RESTIC_REPO -p $RESTIC_PWD_FILE snapshots
            echo "Note the snapshot ID you wish to work with (e.g. faf918cf)"
            ;;
        
        2)
            read -p "Enter snapshot ID: " SNAP_ID
            read -p "Enter directory path to filter (or press enter to show all): " PATH
            restic -r $RESTIC_REPO -p $RESTIC_PWD_FILE ls $SNAP_ID $PATH
            ;;
        
        3)
            read -p "Enter snapshot ID or type 'latest' for the most recent snapshot: " SNAP_ID
            read -p "Enter directory path to restore (or press enter to restore all): " PATH

            TARGET_DIR="/tmp/restore-${SNAP_ID}-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 4)"
            mkdir -p $TARGET_DIR

            LOG_FILE="$TARGET_DIR/restore.json"  # log file path

            if [ -z "$PATH" ]; then
                restic -r $RESTIC_REPO -p $RESTIC_PWD_FILE restore $SNAP_ID --target $TARGET_DIR --json > $LOG_FILE 2>&1 &
            else
                echo "Would you also like to restore the database backup located in $HOME/backup-db? [y/N]"
                read -p "> " DB_CHOICE

                if [ "$DB_CHOICE" == "y" ] || [ "$DB_CHOICE" == "Y" ]; then
                    restic -r $RESTIC_REPO -p $RESTIC_PWD_FILE restore $SNAP_ID --target $TARGET_DIR --include "$PATH" --include "$HOME/backup-db" --json > $LOG_FILE 2>&1 &
                else
                    restic -r $RESTIC_REPO -p $RESTIC_PWD_FILE restore $SNAP_ID --target $TARGET_DIR --include "$PATH" --json > $LOG_FILE 2>&1 &
                fi
            fi
            echo "Restoration started in the background to $TARGET_DIR. Monitor the progress by checking $LOG_FILE."
            ;;

        4)
            # Monitoring ongoing restoration
            PGREP_OUTPUT=$(pgrep -af "restic.*restore")
                
            if [ -z "$PGREP_OUTPUT" ]; then
                echo "No ongoing restoration found"
            else
                # Extract the TARGET_DIR based on your command structure
                TARGET_DIR=$(echo $PGREP_OUTPUT | awk -F'--target ' '{print $2}' | awk '{print $1}')

                if [ -f "$TARGET_DIR/restore.json" ]; then
                    STATUS_LINE=$(tail -n 1 "$TARGET_DIR/restore.json")  # Get the last line from the log, assuming it has the most recent status.
                    
                    # Extract percentage done from the STATUS_LINE
                    PERCENT_DONE=$(echo $STATUS_LINE | sed -n 's/.*"percent_done":\([^,]*\),.*/\1/p')
                    
                    # Convert percentage to a readable format (multiply by 100)
                    PERCENT_DONE=$(awk "BEGIN {print $PERCENT_DONE * 100}")
                    
                    echo "Ongoing restoration to: $TARGET_DIR"
                    echo "Restoration Status: $PERCENT_DONE% completed"
                else
                    echo "Ongoing restoration to: $TARGET_DIR"
                    echo "No log file found in $TARGET_DIR"
                fi
                echo "---------------------------------"
            fi
            ;;

        5)
            PGREP_OUTPUT=$(pgrep -af "restic.*restore")

            if [ -z "$PGREP_OUTPUT" ]; then
                echo "No ongoing restoration found"
            else
                # Extract the TARGET_DIR based on your command structure
                TARGET_DIR=$(echo $PGREP_OUTPUT | awk -F'--target ' '{print $2}' | awk '{print $1}')

                if [ -f "$TARGET_DIR/restore.json" ]; then
                    STATUS_LINE=$(tail -n 1 "$TARGET_DIR/restore.json")  # Get the last line from the log, assuming it has the most recent status.

                    # Extract percentage done from the STATUS_LINE
                    PERCENT_DONE=$(echo $STATUS_LINE | sed -n 's/.*"percent_done":\([^,]*\),.*/\1/p')

                    # Convert percentage to a readable format (multiply by 100)
                    PERCENT_DONE=$(awk "BEGIN {print $PERCENT_DONE * 100}")

                    echo "Ongoing restoration to: $TARGET_DIR"
                    echo "Restoration Status: $PERCENT_DONE% completed"
                else
                    echo "Ongoing restoration to: $TARGET_DIR"
                    echo "No log file found in $TARGET_DIR"
                fi
                echo "---------------------------------"

                PROCESS_ID=$(pgrep -f "restic.*restore")
                read -p "Do you wish to kill the ongoing restoration process? [y/N] " CHOICE
                if [ "$CHOICE" == "y" ] || [ "$CHOICE" == "Y" ]; then
                    kill $PROCESS_ID
                    echo "Restoration process with PID $PROCESS_ID has been terminated."
                else
                    echo "No action taken."
                fi
            fi
            ;;

        6)
            exit 0
            ;;

        *)
            echo "Invalid option, please try again."
            ;;
    esac
    read -p "Press any key to continue..."
done