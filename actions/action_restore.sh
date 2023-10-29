# RESTORE
###########
# The sequence below is executed if the --restore argument is being used.
while true; do
    clear
    echo "Welcome to the interactive restoration menu"
    echo "==========================================="
    echo "1. View snapshots"
    echo "2. List files in a snapshot"
    echo "3. Restore from a snapshot"
    echo "4. Monitor ongoing restoration"
    echo "5. Exit"
    echo "==========================================="
    read -p "Select an option: " choice

    case $choice in
        1)
            restic -r $restic_repo -p $RESTIC_PWD_FILE snapshots
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

            if [ -z "$path" ]; then
                restic -r $restic_repo -p $RESTIC_PWD_FILE restore $snap_id --target $target_dir &
            if [ -z "$path" ]; then
                restic -r $restic_repo -p $RESTIC_PWD_FILE restore $snap_id --target $target_dir &
            else
                echo "Would you also like to restore the database backup located in $HOME/backup-db? [y/N]"
                read -p "> " db_choice

                if [ "$db_choice" == "y" ] || [ "$db_choice" == "Y" ]; then
                    restic -r $restic_repo -p $RESTIC_PWD_FILE restore $snap_id --target $target_dir --include "$path" --include "$HOME/backup-db" &
                else
                    restic -r $restic_repo -p $RESTIC_PWD_FILE restore $snap_id --target $target_dir --include "$path" &
                fi
            fi
            echo "Restoration started in the background to $target_dir"
            ;;

        4)
            # Monitoring ongoing restoration could be a bit trickier. 
            # One way is to check for restic processes:
            pgrep -af "restic.*restore" || echo "No ongoing restoration found"
            ;;

        5)
            exit 0
            ;;
        
        *)
            echo "Invalid option, please try again."
            ;;
    esac
    read -p "Press any key to continue..."
done