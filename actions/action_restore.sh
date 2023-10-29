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
    read -p "Select an option: " choice

    case $choice in
        1)
            restic -r $restic_repo -p $RESTIC_PWD_FILE snapshots
            echo "Note the snapshot ID you wish to work with (e.g. faf918cf)"
            ;;
        
        2)
            read -p "Enter snapshot ID: " snap_id
            read -p "Enter directory path to filter (or press enter to show all): " path
            restic -r $restic_repo -p $RESTIC_PWD_FILE ls $snap_id $path
            ;;
        
        3)
            read -p "Enter snapshot ID or type 'latest' for the most recent snapshot: " snap_id
            read -p "Enter directory path to restore (or press enter to restore all): " path

            target_dir="/tmp/restore-${snap_id}-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 4)"
            mkdir -p $target_dir

            log_file="$target_dir/restore.json"  # log file path

            if [ -z "$path" ]; then
                restic -r $restic_repo -p $RESTIC_PWD_FILE restore $snap_id --target $target_dir --json > $log_file 2>&1 &
            else
                echo "Would you also like to restore the database backup located in $HOME/backup-db? [y/N]"
                read -p "> " db_choice

                if [ "$db_choice" == "y" ] || [ "$db_choice" == "Y" ]; then
                    restic -r $restic_repo -p $RESTIC_PWD_FILE restore $snap_id --target $target_dir --include "$path" --include "$HOME/backup-db" --json > $log_file 2>&1 &
                else
                    restic -r $restic_repo -p $RESTIC_PWD_FILE restore $snap_id --target $target_dir --include "$path" --json > $log_file 2>&1 &
                fi
            fi
            echo "Restoration started in the background to $target_dir. Monitor the progress by checking $log_file."
            ;;

        4)
            # Monitoring ongoing restoration
            pgrep_output=$(pgrep -af "restic.*restore")
                
            if [ -z "$pgrep_output" ]; then
                echo "No ongoing restoration found"
            else
                # Extract the target_dir based on your command structure
                target_dir=$(echo $pgrep_output | awk -F'--target ' '{print $2}' | awk '{print $1}')

                if [ -f "$target_dir/restore.json" ]; then
                    status_line=$(tail -n 1 "$target_dir/restore.json")  # Get the last line from the log, assuming it has the most recent status.
                    
                    # Extract percentage done from the status_line
                    percent_done=$(echo $status_line | sed -n 's/.*"percent_done":\([^,]*\),.*/\1/p')
                    
                    # Convert percentage to a readable format (multiply by 100)
                    percent_done=$(awk "BEGIN {print $percent_done * 100}")
                    
                    echo "Ongoing restoration to: $target_dir"
                    echo "Restoration Status: $percent_done% completed"
                else
                    echo "Ongoing restoration to: $target_dir"
                    echo "No log file found in $target_dir"
                fi
                echo "---------------------------------"
            fi
            ;;

        5)
            pgrep_output=$(pgrep -af "restic.*restore")

            if [ -z "$pgrep_output" ]; then
                echo "No ongoing restoration found"
            else
                # Extract the target_dir based on your command structure
                target_dir=$(echo $pgrep_output | awk -F'--target ' '{print $2}' | awk '{print $1}')

                if [ -f "$target_dir/restore.json" ]; then
                    status_line=$(tail -n 1 "$target_dir/restore.json")  # Get the last line from the log, assuming it has the most recent status.

                    # Extract percentage done from the status_line
                    percent_done=$(echo $status_line | sed -n 's/.*"percent_done":\([^,]*\),.*/\1/p')

                    # Convert percentage to a readable format (multiply by 100)
                    percent_done=$(awk "BEGIN {print $percent_done * 100}")

                    echo "Ongoing restoration to: $target_dir"
                    echo "Restoration Status: $percent_done% completed"
                else
                    echo "Ongoing restoration to: $target_dir"
                    echo "No log file found in $target_dir"
                fi
                echo "---------------------------------"

                process_id=$(pgrep -f "restic.*restore")
                read -p "Do you wish to kill the ongoing restoration process? [y/N] " choice
                if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
                    kill $process_id
                    echo "Restoration process with PID $process_id has been terminated."
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