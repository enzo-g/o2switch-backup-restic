# This function takes one or more directory paths as arguments
# For each directory, it checks if it exists. If it does, it informs the user.
# Otherwise, it attempts to create the directory.
create_directories() {
    for DIR in "$@"; do
        if [ -d "$DIR" ]; then
            echo "Directory $DIR already exists."
        else
            mkdir -p "$DIR"
            if [ $? -eq 0 ]; then
                echo "Directory $DIR created successfully."
            else
                echo "Failed to create directory $DIR."
            fi
        fi
    done
}

# Example usage:
# create_directories "$DIR_ONE" "$DIR_TWO" "$DIR_THREE"
